// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMBackup{
    function profit() external returns(uint256 amountOut,uint256 amountIn);
}


