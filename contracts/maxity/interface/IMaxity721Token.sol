// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interface/IMaxityMetadata.sol";

interface IMaxity721Token{
    function inWhiteList(address who) external view returns (bool) ;
    function mint(address designer,address to,uint [] memory _futureRoyaltys,string []memory uris) external returns (uint256[] memory new_tokenids);
}