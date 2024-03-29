// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenLock {

    function balanceOf(address account) external view returns (uint256);

    function calLockAmount(uint amount) external view returns (uint256);

    function lockRate() external view returns (uint256);

    function lockToken(address account, uint256 amount) external;

    function getReward(address account) external;
    event GetReward(address account,address token, uint256 reward,uint256 currentAmount);
}

