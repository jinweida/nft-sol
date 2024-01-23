// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IMaxityMarketPlace{

    function sellByFixPrice(address _token,uint256[] memory _tokenids,uint[] memory _prices,address seller) external  returns (uint) ;

    function auctionMax721(address _token,uint256[] memory _tokenids,uint [] memory base_prices,uint [] memory incre_prices,uint [] memory  starttimes,uint [] memory deadlines,address seller) external returns (uint amountU);

    function buy(address _token,uint256 _tokenid,address to) external;

    function bid(address _token,uint256 _tokenid,uint256 amount,address to) external returns (bool);

    function auctionOnFixPrice(address _token,uint _tokenid,uint _price,address price_offer,uint deadline)  external returns(uint);
    
    function agreeAuctionOnFixPrice(address _token,uint _tokenid) external;

    function delist(address _token,uint256 _tokenid) external;
    function soldCount(address token,uint id) external view returns(uint);
    
}

