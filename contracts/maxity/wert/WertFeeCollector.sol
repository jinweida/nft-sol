
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import  '../../libraries/TransferHelper.sol';
import '../interface/IReferences.sol';
import '../interface/IFeeCollector.sol';


contract WertFeeCollector is Ownable,IFeeCollector{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    constructor(){
        
    }
    
    event AddReceiver(address indexed to,uint allocPoint,uint totalAllocPoint);
    event RemoveReceiver(address indexed to,uint allocPoint,uint totalAllocPoint);
    event Withdraw(address indexed from,address indexed to,address indexed token,uint amount);
    event WithdrawAll(address indexed from,address indexed to,address indexed token,uint amount);



     // Info of each pool.
    struct RecvInfo {
        uint256 allocPoint;       // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Rewards distribution occurs.
        mapping(address=>uint256) rewardDebt; // Reward debt.
        // uint256 totalReward;    // Total amount of current pool deposit.
    }

    struct BonusInfo {
        IERC20  token;           // Address of LP token contract.
        uint256 lastRewardBlock;  // Last block number that Rewards distribution occurs.
        uint256 totalAmount;    // Total amount of current pool deposit.
    }

    mapping(address=>RecvInfo) public receiverInfos;

    mapping(address=>uint256) public bonusOfPid;

    BonusInfo[] public bonusInfo;



    function pidFromAddr(address _token) external view returns(uint256 pid){
        return bonusOfPid[_token];
    }

    function bonusLength() public view returns (uint256) {
        return bonusInfo.length;
    }


// Update reward variables for all pools. Be careful of gas spending!
    function massUpdateBonus() public onlyOwner {
        uint256 length = bonusInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public onlyOwner {
        BonusInfo storage pool = bonusInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 poolReward = IERC20(pool.token).balanceOf(address(this));
        pool.totalAmount=poolReward;
        pool.lastRewardBlock = block.number;
    }

    function addBonusInfo(IERC20 _token, bool _withUpdate) public onlyOwner {
        require(address(_token) != address(0), "_token is the zero address");
        require(bonusOfPid[address(_token)]==0,"Token already exists");

        require(!(bonusLength()>0 && address(bonusInfo[0].token) == address(_token)),'_token already exist in 0');
        if (_withUpdate) {
            massUpdateBonus();
        }
        uint256 lastRewardBlock = block.number;
        bonusInfo.push(BonusInfo({
            token : _token,
            lastRewardBlock : lastRewardBlock,
            totalAmount : 0
        }));
        bonusOfPid[address(_token)] = bonusLength() - 1;
    }


    uint public totalAllocPoint;


    function addAllocReceiver(address receiver,uint allocPoint)external onlyOwner returns(address){
        uint prevAllocPoint = receiverInfos[receiver].allocPoint;
        receiverInfos[receiver].allocPoint = allocPoint;
        receiverInfos[receiver].lastRewardBlock = block.number;

        totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(allocPoint);
        uint256 length = bonusInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            BonusInfo storage pool = bonusInfo[pid];
            receiverInfos[receiver].rewardDebt[address(pool.token)] = pool.totalAmount.mul(allocPoint).div(totalAllocPoint);
        }

    }

    function removeAllocReceiver(address receiver,uint allocPoint,address remainto)external onlyOwner returns(address){
        require(receiverInfos[receiver].allocPoint>0,"User does not exist");
        uint256 length = bonusInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            BonusInfo storage pool = bonusInfo[pid];
            uint remain = pool.totalAmount.mul(allocPoint).div(totalAllocPoint).sub(receiverInfos[receiver].rewardDebt[address(pool.token)]);
            if(remain>0)
            {
                TransferHelper.safeTransfer(address(pool.token),remainto,remain);
            }
            receiverInfos[receiver].rewardDebt[address(pool.token)] = pool.totalAmount.mul(allocPoint).div(totalAllocPoint);
        }

        receiverInfos[receiver].allocPoint = 0;
        receiverInfos[receiver].lastRewardBlock = block.number;

    }

    function feeShare(address token,uint256 amount)external returns(uint256){
        uint pid = bonusOfPid[token];
        require(address(bonusInfo[pid].token) == token,"Wrong token provided");
        bonusInfo[pid].totalAmount = bonusInfo[pid].totalAmount.add(amount);
    }
    

    function getFeeAmount(address receiver,address token) external view returns(uint256){
        RecvInfo storage recvInfo = receiverInfos[receiver];
        require(recvInfo.allocPoint>0,"Not receiver");
        uint pid = bonusOfPid[token];
        uint amount = bonusInfo[pid].totalAmount;
        return amount.mul(recvInfo.allocPoint).div(totalAllocPoint).sub(recvInfo.rewardDebt[token]);
    }
    function withdraw(address to,address token,uint256 amount)external returns(uint256){
        address receiver = msg.sender;
        RecvInfo storage recvInfo = receiverInfos[receiver];
        require(recvInfo.allocPoint>0,"Not receiver");
        uint pid = bonusOfPid[token];
        uint total_amount = bonusInfo[pid].totalAmount;
        uint userAmount = total_amount.mul(recvInfo.allocPoint).div(totalAllocPoint).sub(recvInfo.rewardDebt[token]);
        require(userAmount>=amount,"Insufficient balance for fees");
        recvInfo.rewardDebt[token] = recvInfo.rewardDebt[token].add(amount);
        TransferHelper.safeTransfer(token,to,amount);
        return amount;
    }


    function withdrawAll(address to,address token)external returns(uint256){
        address receiver = msg.sender;
        RecvInfo storage recvInfo = receiverInfos[receiver];
        require(recvInfo.allocPoint>0,"Not receiver");
        uint pid = bonusOfPid[token];
        uint amount = bonusInfo[pid].totalAmount;
        uint userAmount = amount.mul(recvInfo.allocPoint).div(totalAllocPoint).sub(recvInfo.rewardDebt[token]);
        recvInfo.rewardDebt[token] = recvInfo.rewardDebt[token].add(userAmount);
        TransferHelper.safeTransfer(token,to,userAmount);
        return userAmount;
    }



}
