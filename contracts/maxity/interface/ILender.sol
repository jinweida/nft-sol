// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface ILender{
    function lendUTRatio() external returns(uint256);
    function userLockForLend(address _user,address _lpToken,uint256 _lockAmount,address _pool) external  returns (uint) ;
    function userPayFromRouter(address _user ,address _lpToken,uint256 _utAmount) external ;
}


