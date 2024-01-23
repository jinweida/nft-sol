// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface ICharge {
    function deposit(address token,address to,uint amount,uint deadline) external payable;
    function withdraw(address token,address to,uint amount,uint deadline) external;
}