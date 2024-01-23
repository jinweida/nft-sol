// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IWMATIC {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function approve(address guy, uint wad) external returns (bool) ;
    function balanceOf(address owner) external returns(uint);
}