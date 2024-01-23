
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
import '../interface/IMPool.sol';

contract GUTLender is Ownable ,ILender{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 lockAmount;     // How many LP tokens the user has provided.
        uint256 utAmount;        //already charge fee, charging = feeAccumulated
        uint256 lendStartBlocks;// when start Lend
    }

    // The UT Token!
    IMintableToken public gUT;
    IMintableToken public UT;
    address public mPool;
    
    mapping(address  => mapping(address=>UserInfo)) public userInfos;
    uint256 override public lendUTRatio;
    uint256 public lendUTFee;
    uint256 public blockTimeOut =  1200*24*365;//1 years

    address public feeAddr;
    event UserLend(address indexed user,address indexed lpToken,uint256 lockAmount,uint256 utAmount,address pool);
    event Repayment(address indexed user, uint256 utAmount,uint256 unlockAmount);

    constructor(
        address _ut,
        address _gut,
        address _mPool,
        uint256 _lendUTRatio,//7000
        uint256 _lendUTFee,//9000
        address _feeAddr

    ) public {
        UT = IMintableToken(_ut);
        gUT = IMintableToken(_gut);
        mPool = _mPool;
        lendUTRatio = _lendUTRatio;
        lendUTFee = _lendUTFee;
        feeAddr = _feeAddr;
    }

    function setLendUTRatio(uint256 _lendUTRatio) public onlyOwner {
        lendUTRatio = _lendUTRatio;
    }
    function setLendUTFee(uint256 _lendUTFee) public onlyOwner {
        lendUTFee = _lendUTFee;
    }

     function setLendBlockTimeOut(uint256 _blockTimeOut) public onlyOwner {
        blockTimeOut = _blockTimeOut;
    }
    
    function setFeeAddr(address _feeAddr) public onlyOwner{
        feeAddr=_feeAddr;
    }

    address public bgmRouter;
    function setBGMRouter(address _bgmRouter) public onlyOwner{
        bgmRouter=_bgmRouter;
    }

    function setmPool(address _mPool) public onlyOwner{
        mPool=_mPool;
    }

    function setUTToken(address _ut) public onlyOwner{
        UT = IMintableToken(_ut);
    }

     function setGUTToken(address _gut) public onlyOwner{
        gUT = IMintableToken(_gut);
    }

    function userLockForLend(address _user,address _lpToken,uint256 _lendAmount,address _investpool) external override returns (uint utAmount){
        require(msg.sender==mPool,'only call from pool');
        UserInfo storage user = userInfos[_user][_lpToken];
        utAmount = _lendAmount;//70%
        uint256 _lockAmount = _lendAmount.mul(10000).div(lendUTRatio);
        require(utAmount>0,'ut amount zero');
        user.lockAmount = user.lockAmount.add(_lockAmount);
        user.utAmount = user.utAmount.add(utAmount);
        user.lendStartBlocks = block.number;
        gUT.mint(_user, utAmount);
        emit UserLend(_user,_lpToken,_lockAmount,utAmount,_investpool);
    }

    function userPayFromRouter(address _user ,address _lpToken,uint256 _utAmount) external override {
        require(msg.sender==bgmRouter,'only call from router');
        _userRepay(_user,_lpToken,_utAmount);
    }

    function userRepay(address _lpToken,uint256 _utAmount) external returns (uint unlockAmount){
        return _userRepay(msg.sender,_lpToken,_utAmount);
    }


    // function lenderUnlock(address _lpToken,uint256 _unlockAmount,uint256 _feeAmount,address _unlockuser) external ;
    function _userRepay(address _user ,address _lpToken,uint256 _utAmount) internal returns (uint unlockAmount){
        require(_utAmount>0,'user utAmount error');
        UserInfo storage user = userInfos[_user][_lpToken];
        require(user.utAmount>=_utAmount,'user repay to large');
        unlockAmount = _utAmount.mul(10000).div(lendUTRatio);
        if(unlockAmount>user.lockAmount){
            unlockAmount = user.lockAmount;
        }
        //fee
        uint256 feeAmount = unlockAmount.sub(unlockAmount.mul(lendUTFee).div(10000));
        // gUT.burn(_user,_utAmount);

        user.lockAmount = user.lockAmount.sub(unlockAmount);
        user.utAmount = user.utAmount.sub(_utAmount);
        IERC20(_lpToken).approve(mPool, unlockAmount);
        IMPool(mPool).lenderUnlock(_lpToken,unlockAmount,feeAmount,feeAddr,_user);
    }

    
    function timeOutUserLender(address _user ,address _lpToken) public onlyOwner returns (uint unlockAmount){

        UserInfo storage user = userInfos[_user][_lpToken];
        uint256 _utAmount = user.utAmount;
        require(_utAmount>0,'user has no lend');
        require(user.lendStartBlocks.add(blockTimeOut) > block.number,'user not  timeout');

        unlockAmount = _utAmount.mul(10000).div(lendUTRatio);
        if(unlockAmount>user.lockAmount){
            unlockAmount = user.lockAmount;
        }
        //fee
       uint256 feeAmount = unlockAmount.sub(unlockAmount.mul(lendUTFee).div(10000));

        gUT.burn(_user,_utAmount);
        user.lockAmount = user.lockAmount.sub(unlockAmount);
        user.utAmount = user.utAmount.sub(_utAmount);
        IERC20(_lpToken).approve(mPool, unlockAmount);
        IMPool(mPool).lenderUnlock(_lpToken,unlockAmount,feeAmount,feeAddr,_user);
        

    }

    function emergencyUT(uint256 amount,address to) public onlyOwner {
        require(UT.balanceOf(address(this)) >= amount, "Insufficient contract balance");
        UT.transfer(to, amount);
    }

}
