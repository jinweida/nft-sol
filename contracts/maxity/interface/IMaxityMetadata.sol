// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Interface for the optional metadata functions from the Maxity  standard.
 *
 * _Available since v4.1._
 */
interface IMaxityMetadata is IERC721 {
    /**
     * @dev Returns the ngo of the token.
     */
    function ngo() external view returns (address);

    /**
     * @dev Returns the did of the token.
     */
    function did() external view returns (string memory);


    /**
     * @dev Returns the disigner of the token.
     */
    function disigner(uint256 _tokenid) external view returns (address);


    /**
     * @dev Returns the ngowallet of the token.
     */
    function ngowallet() external view returns (address);


    /**
     * @dev Returns the futureRoyalty of the tokenid
     */
    function futureRoyalty(uint256 _tokenid)  external view returns (uint);
}
