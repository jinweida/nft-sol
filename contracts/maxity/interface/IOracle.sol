// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IOracle {
    function update(address tokenA, address tokenB) external;
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);
}

