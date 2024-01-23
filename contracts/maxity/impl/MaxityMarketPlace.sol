// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import  '../../libraries/TransferHelper.sol';

import "../interface/IMaxityMarketPlace.sol";
import "../interface/IMaxity721Token.sol";
import "../interface/IMaxityMetadata.sol";

contract MaxityMarketPlace is Ownable,Pausable ,IMaxityMarketPlace,IERC721Receiver,ReentrancyGuard{
    using SafeMath for uint256;

    event TokenIdOnSale(address indexed _token,uint256 indexed _tokenid,address indexed seller,uint256 fixprice);

    event TokenIdOnAuctionByPrice(address indexed _token,uint256 indexed _tokenid,address indexed buyer,uint256 price);

    event TokenIdDelist(address indexed _token,uint256 indexed _tokenid,address indexed seller);

    event TokenIdOnAuction(address indexed _token,uint256 indexed _tokenid,address indexed seller,uint base_price,uint incre_price,uint deadline);

    event BidOnTokenId(address indexed _token,uint256 indexed _tokenid,address indexed buyer,uint bid_price);


    enum TradeMode{
        FIX_PRICE ,
        BID_PRICE,
        AUCTION_ON_FIX_PRICE,
        UNKNOW
    }

    event TokenIdSaled(address indexed _token,uint256 indexed _tokenid,address  buyer,address  seller,uint256 price,uint sold_count,TradeMode mode);

    struct SaleInfo{
        bool isAuction;
        uint256 fixprice;
        uint base_price;
        uint incre_price;
        uint starttime;
        uint deadline;
        uint cur_bid_price;
        address price_offer;
        address seller;
        bool firstSell;
    }

   

    mapping(address=>mapping(uint => SaleInfo))  public marketUnits;
    mapping(address=>mapping(uint=>uint)) public soldCount;
    address public ut;
    address public feeTo;
    
    constructor(address _ut,address _feeTo) {
        ut = _ut;
        feeTo = _feeTo;
        
    }
    function setUTToken(address _ut) onlyOwner public{ 
        ut = _ut;
    }


    function setFeeTo(address _feeTo) onlyOwner public{ 
        feeTo = _feeTo;
    }


    function sellByFixPrice(address _token,uint256[] memory _tokenids,uint [] memory _prices,address _seller) nonReentrant external  returns (uint) {
            
        uint256 length = _tokenids.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            uint256 _tokenid=_tokenids[pid];
            require(marketUnits[_token][_tokenid].seller==address(0x0),"Token already on the marketplace");
            SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
            if(IERC721(_token).ownerOf(_tokenid)!=address(this)){//first mint
                IERC721(_token).transferFrom(msg.sender, address(this), _tokenid);
            }
            saleInfo.seller = _seller;
            // 
            saleInfo.isAuction = false;
            saleInfo.fixprice = _prices[pid];
            emit TokenIdOnSale(_token,_tokenid,saleInfo.seller,_prices[pid]);
        }
        return length;
    }

    function onERC721Received( address , address , uint256 , bytes calldata  ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function auctionMax721(address _token,uint256[] memory _tokenids,uint[] memory base_prices,uint [] memory incre_prices,uint[] memory starttimes,uint[] memory deadlines,address _seller) external 
    nonReentrant returns (uint amountU){
        uint256 length = _tokenids.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            uint256 _tokenid=_tokenids[pid];
            require(marketUnits[_token][_tokenid].seller==address(0x0),"Token already on the marketplace");
            SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
             if(IERC721(_token).ownerOf(_tokenid)!=address(this)){//first mint
                IERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenid);                
            }
            saleInfo.seller = _seller;
            // 
            saleInfo.isAuction = true;
            saleInfo.base_price = base_prices[pid];
            saleInfo.incre_price = incre_prices[pid];
            saleInfo.starttime = starttimes[pid];
            saleInfo.deadline = deadlines[pid];
            saleInfo.cur_bid_price = base_prices[pid];
            emit TokenIdOnAuction(_token,_tokenid,saleInfo.seller,base_prices[pid],incre_prices[pid],deadlines[pid]);
        }
        return length;
    }

    function buy(address _token,uint256 _tokenid,address to) public nonReentrant  {
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(!saleInfo.isAuction,"This token is on auction");
        //calc fee.
        TransferHelper.safeTransferFrom(ut, msg.sender, address(this), saleInfo.fixprice);
        
        if(saleInfo.price_offer!=address(0x0) && saleInfo.cur_bid_price >0){
            TransferHelper.safeTransfer(ut, saleInfo.price_offer,saleInfo.cur_bid_price);
        }

        tradeDone(_token,_tokenid,saleInfo.fixprice,to,TradeMode.FIX_PRICE);
    }


    function auctionOnFixPrice(address _token,uint _tokenid,uint _price,address price_offer,uint deadline) public nonReentrant  override returns(uint) {
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(!saleInfo.isAuction,"This token is on auction");
        require(_price > saleInfo.cur_bid_price,"Bid price lower than current");

        TransferHelper.safeTransferFrom(ut, msg.sender, address(this), _price);
        if(saleInfo.price_offer!=address(0x0) && saleInfo.cur_bid_price >0){
            TransferHelper.safeTransfer(ut, saleInfo.price_offer,saleInfo.cur_bid_price);
        }
        saleInfo.cur_bid_price = _price;
        saleInfo.price_offer = price_offer;
        emit TokenIdOnAuctionByPrice(_token,_tokenid,price_offer,_price);
        return 0;
    }

     function agreeAuctionOnFixPrice(address _token,uint _tokenid) public nonReentrant  override {
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(!saleInfo.isAuction,"This token is on auction");
        require(saleInfo.seller==msg.sender || owner() == _msgSender(),"Only seller or owner can make agreement");
        require(saleInfo.price_offer!=address(0x0) && saleInfo.cur_bid_price >0,"No auction created");

        tradeDone(_token, _tokenid, saleInfo.cur_bid_price, saleInfo.price_offer,TradeMode.AUCTION_ON_FIX_PRICE);
        
    }



   function delist(address _token,uint256 _tokenid) public nonReentrant override {
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(!saleInfo.isAuction,"This token is on auction");
        require(saleInfo.seller==msg.sender || owner() == _msgSender(),"Only seller or owner can make delist");
        
        if(saleInfo.price_offer!=address(0x0) && saleInfo.cur_bid_price >0){
            TransferHelper.safeTransfer(ut, saleInfo.price_offer,saleInfo.cur_bid_price);
        }

        IERC721(_token).transferFrom(address(this), saleInfo.seller, _tokenid);
        saleInfo.seller = address(0x0);
        emit TokenIdDelist(_token,_tokenid,msg.sender);

    }

    function bid(address _token,uint256 _tokenid,uint256 amount,address to) public nonReentrant returns (bool){
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(saleInfo.isAuction,"This token is not on auction");
        require(block.timestamp >= saleInfo.starttime,"Auction have not started");
        
        if(checkAuctionDone(_token,_tokenid)){
            return false;
        }else{
            uint256 nextbidPrice = saleInfo.cur_bid_price.add(saleInfo.incre_price);
            if(amount>=nextbidPrice){
                TransferHelper.safeTransferFrom(ut, msg.sender, address(this), amount);
                TransferHelper.safeTransfer(ut, saleInfo.price_offer, saleInfo.cur_bid_price);
                saleInfo.price_offer = to;
                saleInfo.cur_bid_price = amount;
                emit BidOnTokenId(_token,_tokenid,to,amount);
                return true;
            }else{
                return false;
            }
        }
    }

    function tradeDone(address _token,uint256 _tokenid,uint total_amount,address buyer,TradeMode mode) internal {
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        uint256 feeAmount = total_amount.mul(2).div(100);
        TransferHelper.safeTransfer(ut, feeTo, feeAmount);
        
        uint256 amount = total_amount.sub(feeAmount);
        if(soldCount[_token][_tokenid]==0){//first sell
            if(IMaxityMetadata(_token).disigner(_tokenid)==address(0x0)){
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).ngowallet(),total_amount.mul(98).div(100));
            }else{//ngo has no designer ability
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).ngowallet(), total_amount.mul(90).div(100));//to ngo
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).disigner(_tokenid), total_amount.mul(8).div(100));//to designer
            }
            soldCount[_token][_tokenid] = 1;
        }else{//2nd saled
            uint256 futureSaleAmount = amount.mul(IMaxityMetadata(_token).futureRoyalty(_tokenid)).div(1e8);
            uint256 remainAmount = amount.sub(futureSaleAmount);
            if(IMaxityMetadata(_token).disigner(_tokenid)==address(0x0)){ //ngo has ability to design nft
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).ngowallet(),futureSaleAmount);
            }else{//ngo has no designer ability
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).ngowallet(), futureSaleAmount.mul(80).div(100));//to ngo
                TransferHelper.safeTransfer(ut, IMaxityMetadata(_token).disigner(_tokenid), futureSaleAmount.mul(20).div(100));//to designer
            }
            TransferHelper.safeTransfer(ut, saleInfo.seller,remainAmount);
             soldCount[_token][_tokenid] =  soldCount[_token][_tokenid] + 1;
        } 
        IERC721(_token).transferFrom(address(this), buyer, _tokenid);
        emit TokenIdSaled(_token,_tokenid, buyer,saleInfo.seller,amount, soldCount[_token][_tokenid],mode);
        saleInfo.seller = address(0x0);
    }


    function checkAuctionDone(address _token,uint256 _tokenid) internal returns(bool){
        //calc fee.
        SaleInfo storage saleInfo = marketUnits[_token][_tokenid];
        require(saleInfo.seller!=address(0x0),"This token is not for sale");
        require(IERC721(_token).ownerOf(_tokenid)==address(this),"This token is not on the marketplace");
        require(saleInfo.isAuction,"This token is not on auction");
        if(saleInfo.deadline >= block.timestamp){
            tradeDone(_token,_tokenid,saleInfo.cur_bid_price,saleInfo.price_offer,TradeMode.BID_PRICE);
            return true;
        }else{
            return false;
        }   
    }


    function emergencyWithdraw(address token,address to) external  onlyOwner {
        uint amount = IERC20(token).balanceOf(address(this));
        if(amount>0){
            TransferHelper.safeTransfer(token,to, amount);
        }

    }

    function emergencyWithdrawNFT(address token,uint256 tokenId,address to) external  onlyOwner {
        uint amount = IERC20(token).balanceOf(address(this));
        if(amount>0){
            IERC721(token).safeTransferFrom(address(this), to, tokenId);
        }

    }

}
