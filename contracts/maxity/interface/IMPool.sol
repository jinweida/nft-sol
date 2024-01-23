// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMPool{
    function lenderUnlock(address _lpToken,uint256 _unlockAmount,uint256 _feeAmount,address _feeAddr,address _unlockuser) external ;
    function deposit(uint256 _pid, uint256 _amount,address _to) external ;
    function pidFromLPAddr(address _lpToken) external view returns(uint);
    function userLock(uint256 _pid,uint256 _lockAmount,address _lender) external ; 
    function userLockFromRouter(address _user ,uint256 _pid,uint256 _lockAmount,address _lender) external;
}


