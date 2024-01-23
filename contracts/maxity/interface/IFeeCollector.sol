// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IFeeCollector {
    function addAllocReceiver(address receiver,uint allocPoint)external returns(address);
    function removeAllocReceiver(address receiver,uint allocPoint,address remainto)external returns(address);
    function feeShare(address token,uint256 amount)external returns(uint256);
    function getFeeAmount(address receiver,address token) external view returns(uint256);
    function withdraw(address to,address token,uint256 amount)external returns(uint256);
    function withdrawAll(address to,address token)external returns(uint256);
}