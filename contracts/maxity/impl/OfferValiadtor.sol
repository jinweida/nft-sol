pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OfferValiadtor is EIP712 {
    using SafeMath for uint256;
    bytes32 public constant OFFER_ITEM_TYPE_HASH = keccak256(        
        "auctionOnFixPrice(address _token,uint _tokenid,uint _price,address price_offer,uint deadline)"   
    );
    constructor() EIP712("OfferValiadtor","1.0"){

    }

    function recoverV4(
        address _token,
        uint _tokenid,
        uint _price,
        address _price_offer,
        uint _deadline,
        bytes memory signature
    ) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    OFFER_ITEM_TYPE_HASH,_token,_tokenid,_price,_price_offer,_deadline
                )
            ));

        return ECDSA.recover(digest, signature);
    }

    function verify(
        address _from,
        address _token,
        uint _tokenid,
        uint _price,
        address _price_offer,
        uint _deadline,
        bytes memory signature
    ) public view returns (bool) {
        address signer = recoverV4(_token, _tokenid, _price, _price_offer,_deadline,signature);
        return signer == _from;
    }

}