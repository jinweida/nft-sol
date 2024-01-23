// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IReferences {
    function rewardUpper(address ref,uint256 amount) external  returns (uint256) ;
    function withdraw() external ;
}

interface IReferenceStore{ 
    function setUpper(address user,address upper,address distributor,bytes memory extdata) external returns(bool);
    function getUpper(address _user) external  view returns (address);
    function setUserExtData(address _user,bytes memory extdata) external ;
    function getUserExtData(address _user) external view returns(bytes memory);
}
