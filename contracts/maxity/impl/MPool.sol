
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import '../interface/IMintableToken.sol';
import  '../../libraries/TransferHelper.sol';
import '../interface/IReferences.sol';
import '../interface/ILender.sol';
import '../interface/IMasterChef.sol';
import '../interface/IMPool.sol';

contract MPool is Ownable ,IMPool{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _multLP;


    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 lockedAmount;// user lend Amount
        uint256 multLpRewardDebt; //multLp Reward debt.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Rewards distribution occurs.
        uint256 accRewardPerShare; // Accumulated Rewards per share, times 1e12.
        uint256 accMultLpPerShare; //Accumulated multLp per share
        uint256 totalAmount;    // Total amount of current pool deposit.
        address investPool;     // token direct to invest Pool
    }

    // The Maxity Token!
    IMintableToken public MAX;
    
    IReferences public refs;
    uint256 public blockRewards;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    mapping(address=>mapping(address => mapping(uint256 => uint256))) public lockAmounts;
    // pid corresponding address
    mapping(address => uint256) public LpOfPid;
        // Corresponding to the pid of the multLP pool
    mapping(uint256 => uint256) public poolCorrespond;

    // Control mining
    bool public paused = false;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when MAX mining starts.
    uint256 public startBlock;
    
    // multLP MasterChef
    address public multLpChef;

    // multLP Token
    address public multLpToken;

    

    
    event Deposit(address indexed user,address indexed touser, uint256 indexed pid, uint256 amount);
    event LockPool(address indexed user, uint256 indexed pid,address indexed to, uint256 lockAmount,uint256 transferAmount);
    event UnLockPool(address indexed user, uint256 indexed pid,address indexed from, uint256 unlockAmount,uint256 transferAmount);

    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount,address indexed _to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount,address indexed _to);

    constructor(
        address _MAX,
        address _refs,
        uint256 _blockRewards, //110
        uint256 _startBlock
        
    ) public {
        MAX = IMintableToken(_MAX);
        refs = IReferences(_refs);
        blockRewards = _blockRewards;
        startBlock = _startBlock;
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        startBlock = _startBlock;
    }

    address public MAXRouter;
    function setMAXRouter(address _MAXRouter) public onlyOwner{
        MAXRouter=_MAXRouter;
    }
    
    function setRefs(address _refs) public onlyOwner{
        refs = IReferences(_refs);
    }

    function setBlockRewards(uint256 _blockRewards) public onlyOwner {
        blockRewards = _blockRewards;
    }

// The current pool corresponds to the pid of the multLP pool
    function setPoolCorr(uint256 _pid, uint256 _sid) public onlyOwner {
        require(_pid <= poolLength() - 1, "Unable to find pool");
        poolCorrespond[_pid] = _sid;
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    uint256 public constant MAXV = type(uint256).max;


    function addMultLP(address _addLP) public onlyOwner returns (bool) {
        require(_addLP != address(0), "LP is zero address");
        IERC20(_addLP).approve(multLpChef, MAXV);
        return EnumerableSet.add(_multLP, _addLP);
    }

    function isMultLP(address _LP) public view returns (bool) {
        return EnumerableSet.contains(_multLP, _LP);
    }

    function getMultLPLength() public view returns (uint256) {
        return EnumerableSet.length(_multLP);
    }

    function getMultLPAddress(uint256 _pid) public view returns (address){
        require(_pid <= getMultLPLength() - 1, "Unable to find multLP");
        return EnumerableSet.at(_multLP, _pid);
    }

    function setPause() public onlyOwner {
        paused = !paused;
    }

    function setMultLP(address _multLpToken, address _multLpChef) public onlyOwner {
        require(_multLpToken != address(0) && _multLpChef != address(0), "Is zero address");
        multLpToken = _multLpToken;
        multLpChef = _multLpChef;
    }

    function replaceMultLP(address _multLpToken, address _multLpChef) public onlyOwner {
        require(_multLpToken != address(0) && _multLpChef != address(0), "Is zero address");
        require(paused == true, "No mining suspension");
        multLpToken = _multLpToken;
        multLpChef = _multLpChef;
        uint256 length = getMultLPLength();
        while (length > 0) {
            address dAddress = EnumerableSet.at(_multLP, 0);
            uint256 pid = LpOfPid[dAddress];
            IMasterChef(multLpChef).emergencyWithdraw(poolCorrespond[pid]);
            EnumerableSet.remove(_multLP, dAddress);
            length--;
        }
    }
    
    function pidFromLPAddr(address _token)external override view returns(uint256 pid){
        return LpOfPid[_token];
    }

    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate,address _investPool) public onlyOwner {
        require(address(_lpToken) != address(0), "_lpToken is zero address");
        require(LpOfPid[address(_lpToken)]==0,'_lpToken already exist');

        require(!(poolLength()>0&& address(poolInfo[0].lpToken) == address(_lpToken)),'_lpToken already exist in 0');
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accRewardPerShare : 0,
            accMultLpPerShare : 0,
            totalAmount : 0,
            investPool: _investPool
        }));
        LpOfPid[address(_lpToken)] = poolLength() - 1;
    }

    // Update the given pool's MAX allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function reward(uint256 blockNumber) public view returns (uint256 ) {
        return  (blockNumber.sub(startBlock).sub(1)).mul(blockRewards);
    }

    function getBlockRewards(uint256 _lastRewardBlock) public view returns (uint256) {
        if(block.number>startBlock){
            if(_lastRewardBlock<=startBlock)
            {
                return  (block.number.sub(startBlock).sub(1)).mul(blockRewards);
            }else{
                return  (block.number.sub(_lastRewardBlock).sub(1)).mul(blockRewards);
            }
        }
        else{
            return 0;
        }
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockReward = getBlockRewards(pool.lastRewardBlock);
        if (blockReward <= 0) {
            return;
        }
        uint256 poolReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
        bool minRet = MAX.mint(address(this), poolReward);
        if (minRet) {
            pool.accRewardPerShare = pool.accRewardPerShare.add(poolReward.mul(1e12).div(lpSupply));
        }
        pool.lastRewardBlock = block.number;
    }

    function allPending( address _user) external view returns (uint256 totalRewardAmount, uint256 totalTokenAmount){
        uint256 length = poolInfo.length;
        for (uint256 _pid = 0; _pid < length; ++_pid) {
            (uint256 rewardAmount, uint256 tokenAmount) = pending(_pid, _user);
            totalRewardAmount = totalRewardAmount.add(rewardAmount);
            totalTokenAmount = totalTokenAmount.add(tokenAmount);
        }
    }

      // View function to see pending rewards on frontend.
    function pending(uint256 _pid, address _user) public view returns (uint256, uint256){
        PoolInfo storage pool = poolInfo[_pid];
        if (isMultLP(address(pool.lpToken))) {
            (uint256 rewardAmount, uint256 tokenAmount) = pendingRewardsAndTokens(_pid, _user);
            return (rewardAmount, tokenAmount);
        } else {
            uint256 rewardAmount = pendingRewards(_pid, _user);
            return (rewardAmount, 0);
        }
    }

    function pendingRewardsAndTokens(uint256 _pid, address _user) private view returns (uint256, uint256){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 accMultLpPerShare = pool.accMultLpPerShare;
        if (user.amount > 0) {
            uint256 TokenPending = IMasterChef(multLpChef).pending(poolCorrespond[_pid], address(this));
            accMultLpPerShare = accMultLpPerShare.add(TokenPending.mul(1e12).div(pool.totalAmount));
            uint256 userPending = user.amount.mul(accMultLpPerShare).div(1e12).sub(user.multLpRewardDebt);
            if (block.number > pool.lastRewardBlock) {
                uint256 blockReward = getBlockRewards(pool.lastRewardBlock);
                uint256 poolReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
                accRewardPerShare = accRewardPerShare.add(poolReward.mul(1e12).div(pool.totalAmount));
                return (user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt), userPending);
            }
            if (block.number == pool.lastRewardBlock) {
                return (user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt), userPending);
            }
        }
        return (0, 0);
    }

    function pendingRewards(uint256 _pid, address _user) private view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        // uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 lpSupply = pool.totalAmount;
        if (user.amount > 0) {
            if (block.number > pool.lastRewardBlock) {
                uint256 blockReward = getBlockRewards(pool.lastRewardBlock);
                uint256 poolReward = blockReward.mul(pool.allocPoint).div(totalAllocPoint);
                accRewardPerShare = accRewardPerShare.add(poolReward.mul(1e12).div(lpSupply));
                return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
            }
            if (block.number == pool.lastRewardBlock) {
                return user.amount.mul(accRewardPerShare).div(1e12).sub(user.rewardDebt);
            }
        }
        return 0;
    }

     // Deposit LP tokens to Pool for DDX allocation.
    function deposit(uint256 _pid, uint256 _amount,address _to) public override notPause {
        PoolInfo storage pool = poolInfo[_pid];
        if (isMultLP(address(pool.lpToken))) {
            depositMultLP(_pid, _amount, msg.sender,_to);
        } else {
            depositLP(_pid, _amount, msg.sender,_to);
        }
    }

    function depositMultLP(uint256 _pid, uint256 _amount, address _user,address _to) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_to];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingAmount > 0) {
                safeRewardTransfer(_to, pendingAmount);
            }
            uint256 beforeToken = IERC20(multLpToken).balanceOf(address(this));
            IMasterChef(multLpChef).deposit(poolCorrespond[_pid], 0);
            uint256 afterToken = IERC20(multLpToken).balanceOf(address(this));
            pool.accMultLpPerShare = pool.accMultLpPerShare.add(afterToken.sub(beforeToken).mul(1e12).div(pool.totalAmount));
            uint256 tokenPending = user.amount.mul(pool.accMultLpPerShare).div(1e12).sub(user.multLpRewardDebt);
            if (tokenPending > 0) {
                IERC20(multLpToken).safeTransfer(_to, tokenPending);
            }
        }
        if (_amount > 0) {
            if(pool.investPool==address(0x0))
            {
                pool.lpToken.safeTransferFrom(_user, address(this), _amount);
            }else{
                pool.lpToken.safeTransferFrom(_user, pool.investPool, _amount);
            }

            if (pool.totalAmount == 0) {
                IMasterChef(multLpChef).deposit(poolCorrespond[_pid], _amount);
                user.amount = user.amount.add(_amount);
                pool.totalAmount = pool.totalAmount.add(_amount);
            } else {
                uint256 beforeToken = IERC20(multLpToken).balanceOf(address(this));
                IMasterChef(multLpChef).deposit(poolCorrespond[_pid], _amount);
                uint256 afterToken = IERC20(multLpToken).balanceOf(address(this));
                pool.accMultLpPerShare = pool.accMultLpPerShare.add(afterToken.sub(beforeToken).mul(1e12).div(pool.totalAmount));
                user.amount = user.amount.add(_amount);
                pool.totalAmount = pool.totalAmount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        user.multLpRewardDebt = user.amount.mul(pool.accMultLpPerShare).div(1e12);
        emit Deposit(_user,_to, _pid, _amount);
    }


    // Deposit LP tokens to Pool for Rewards allocation.
    function depositLP(uint256 _pid, uint256 _amount,address _user, address _to) private  {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_to];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingAmount > 0) {
                safeRewardTransfer(_to, pendingAmount);
            }
        }
        if (_amount > 0) {
            // pool.lpToken.safeTransferFrom(_user, address(this), _amount);
            if(pool.investPool==address(0x0))
            {
                pool.lpToken.safeTransferFrom(_user, address(this), _amount);
            }else{
                pool.lpToken.safeTransferFrom(_user, pool.investPool, _amount);
            }
            
            user.amount = user.amount.add(_amount);
            pool.totalAmount = pool.totalAmount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Deposit(_user,_to, _pid, _amount);
    }

    function userLock(uint256 _pid,uint256 _lendAmount,address _lender) external notPause override  {
        _userLock(msg.sender,_pid,_lendAmount,_lender);
    }

    function userLockFromRouter(address _user ,uint256 _pid,uint256 _lendAmount,address _lender) external notPause override{
        require(msg.sender==MAXRouter,'only call from router');
        _userLock(_user,_pid,_lendAmount,_lender);
    }

    function _userLock(address _user , uint256 _pid,uint256 _lendAmount,address _lender) private {
        require(_lendAmount>0,'lend amount zero');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(user.amount>0,'user have no lp amount');
        uint256 _lockAmount = _lendAmount.mul(10000).div(ILender(_lender).lendUTRatio());
        require(user.lockedAmount.add(_lockAmount) <= user.amount,'not enough amount');

        if(pool.investPool==address(0x0))
        {//token in this contract
            // pool.lpToken.safeTransferFrom(_user, address(this), _amount);
            pool.lpToken.safeTransfer(_lender, _lockAmount);
            emit LockPool(_user,_pid,_lender,_lockAmount,_lockAmount);
        }else{
            //token in invest pool
            // pool.lpToken.safeTransferFrom(_user, pool.investPool, _amount);
            emit LockPool(_user,_pid,_lender,_lockAmount,0);
        }

        lockAmounts[_lender][_user][_pid] = lockAmounts[_lender][_user][_pid].add(_lockAmount);
        user.lockedAmount = user.lockedAmount.add(_lockAmount);
        
        ILender(_lender).userLockForLend(_user,address(pool.lpToken), _lendAmount, pool.investPool);
        
    }

    function lenderUnlock(address _lpToken,uint256 _unlockAmount,uint256 _feeAmount,address _feeAddr,address _unlockuser) external override notPause {
        require(_unlockAmount>0,'unlock amount zero');
        require(_feeAmount<=_unlockAmount,'fee Amount error');

        address _lender = msg.sender;
        uint256 _pid = LpOfPid[_lpToken];

        require(lockAmounts[_lender][_unlockuser][_pid]>=_unlockAmount,'unlock amount exceed');
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_unlockuser];

        require(user.amount>=_unlockAmount,'user lp amount ?');
        require(user.lockedAmount>=_unlockAmount,'user locked amount ?');

        if(pool.investPool==address(0x0))
        {//token in this contract
            // pool.lpToken.safeTransferFrom(_user, address(this), _amount);
            if(_unlockAmount>_feeAmount){
                if(_feeAddr==address(0x0))
                {
                    pool.lpToken.safeTransferFrom(_lender, address(this), _unlockAmount.sub(_feeAmount));
                }else{
                    pool.lpToken.safeTransferFrom(_lender, _feeAddr, _unlockAmount.sub(_feeAmount));
                }
            }
            emit UnLockPool(_unlockuser,_pid,_lender,_unlockAmount,_unlockAmount.sub(_feeAmount));
        }else{
            //token in invest pool
            emit UnLockPool(_unlockuser,_pid,_lender,_unlockAmount,0);
        }        
        user.lockedAmount = user.lockedAmount.sub(_unlockAmount);
        lockAmounts[_lender][_unlockuser][_pid]=lockAmounts[_lender][_unlockuser][_pid].sub(_unlockAmount);
        if(_feeAmount>0){
            updatePool(_pid);
            uint256 pendingAmount = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pendingAmount > 0) {
                safeRewardTransfer(_unlockuser, pendingAmount);
            }
            user.amount = user.amount.sub(_feeAmount);
            pool.totalAmount = pool.totalAmount.sub(_feeAmount);
            user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        }
        
    }

    // Withdraw LP tokens from Pool.
    function withdraw(uint256 _pid, uint256 _amount,address _to) public notPause {
        PoolInfo storage pool = poolInfo[_pid];
        if (isMultLP(address(pool.lpToken))) {
            withdrawRewardsAndTokens(_pid, _amount, msg.sender,_to);
        } else {
            withdrawRewards(_pid, _amount, msg.sender,_to);
        }
    }

    function withdrawRewardsAndTokens(uint256 _pid, uint256 _amount, address _user,address _to) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(user.amount.sub(user.lockedAmount) >= _amount, "Withdrawal not possible");

        updatePool(_pid);
        uint256 pendingAmount = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pendingAmount > 0) {
            safeRewardTransfer(_to, pendingAmount);
        }
        if (_amount > 0) {
            uint256 beforeToken = IERC20(multLpToken).balanceOf(address(this));
            IMasterChef(multLpChef).withdraw(poolCorrespond[_pid], _amount);
            uint256 afterToken = IERC20(multLpToken).balanceOf(address(this));
            pool.accMultLpPerShare = pool.accMultLpPerShare.add(afterToken.sub(beforeToken).mul(1e12).div(pool.totalAmount));
            uint256 tokenPending = user.amount.mul(pool.accMultLpPerShare).div(1e12).sub(user.multLpRewardDebt);
            if (tokenPending > 0) {
                IERC20(multLpToken).safeTransfer(_to, tokenPending);
            }
            user.amount = user.amount.sub(_amount);
            pool.totalAmount = pool.totalAmount.sub(_amount);
            pool.lpToken.safeTransfer(_to, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        user.multLpRewardDebt = user.amount.mul(pool.accMultLpPerShare).div(1e12);
        emit Withdraw(_user, _pid, _amount,_to);
    }

    // Withdraw LP tokens from Pool.
    function withdrawRewards(uint256 _pid, uint256 _amount, address _user, address _to) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        require(user.amount.sub(user.lockedAmount) >= _amount, "Withdrawal not possible");
        updatePool(_pid);

        uint256 pendingAmount = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pendingAmount > 0) {
            safeRewardTransfer(_to, pendingAmount);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            require(user.amount>=user.lockedAmount, "Wrong locked amount provided");
            pool.totalAmount = pool.totalAmount.sub(_amount);
            pool.lpToken.safeTransfer(_to, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Withdraw(_user, _pid, _amount,_to);
    }

     // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyNative(uint256 amount) public onlyOwner {
        TransferHelper.safeTransferNative(msg.sender,amount)  ;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid,address _to) public notPause {
        PoolInfo storage pool = poolInfo[_pid];
        if (isMultLP(address(pool.lpToken))) {
            emergencyWithdrawRewardsAndToken(_pid, msg.sender,_to);
        } else {
            emergencyWithdrawRewards(_pid, msg.sender,_to);
        }
    }
    function emergencyWithdrawRewardsAndToken(uint256 _pid, address _user,address _to) private {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 amount = user.amount.sub(user.lockedAmount);
        uint256 beforeToken = IERC20(multLpToken).balanceOf(address(this));
        IMasterChef(multLpChef).withdraw(poolCorrespond[_pid], amount);
        uint256 afterToken = IERC20(multLpToken).balanceOf(address(this));
        pool.accMultLpPerShare = pool.accMultLpPerShare.add(afterToken.sub(beforeToken).mul(1e12).div(pool.totalAmount));
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpToken.safeTransfer(_to, amount);
        pool.totalAmount = pool.totalAmount.sub(amount);
        emit EmergencyWithdraw(_user, _pid, amount,_to);
    }


    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdrawRewards(uint256 _pid, address _user,address _to) private{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 amount = user.amount.sub(user.lockedAmount);
        user.amount = user.amount.sub(amount);
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        pool.lpToken.safeTransfer(_to, amount);
        pool.totalAmount = pool.totalAmount.sub(amount);
        emit EmergencyWithdraw(_user, _pid, amount,_to);
    }

    // Safe MAX transfer function, just in case if rounding error causes pool to not have enough MAXs.
    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 MAXBal = MAX.balanceOf(address(this));
        if (_amount > MAXBal) {
            _amount = MAXBal;
        }
        //reward to referer.
        if(address(refs)!=address(0x0)){
            refs.rewardUpper(_to,_amount);
        }
        MAX.transfer(_to, _amount);
    }

    modifier notPause() {
        require(paused == false, "Mining has been suspended");
        _;
    }

}
