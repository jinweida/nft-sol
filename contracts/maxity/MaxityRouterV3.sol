// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import './interface/IMintableToken.sol';
import './interface/ILPToken.sol';
import '../libraries/TransferHelper.sol';
import './interface/IGame.sol';
import './interface/IMPool.sol';
import './interface/IMBackup.sol';
import './impl/UTToken.sol';
import './impl/ReferencesStore.sol';
import './interface/IMasterChef.sol';
import './interface/IMRouter.sol';
import './interface/ILender.sol';
import './interface/IMaxity721Token.sol';
import './interface/IMaxityMarketPlace.sol';
import './interface/IWMATIC.sol';

contract MaxityRouterV3 is Ownable,IMRouter,ReentrancyGuard{
    using SafeMath for uint256;
    address public maxityPool;
    address public maxityBackup;
    address public tokenU;
    address public lptoken;
    address public feeTo;
    address public sweeper;
    address public refStore;
    address public maxityRefs;
    address public maxityProfitShare;
    address public wrappedNative;

    mapping(address => IGame)  public games;
    
    constructor(address _wrappedNative) {
        // tokenU = _tokenU;
        wrappedNative = _wrappedNative;
        // maxityPool = _maxityPool;
        // lptoken = _lptoken;
        // feeTo = _feeTo;
        // sweeper= _sweeper;
    }
    function setTokenU (address _tokenU) public onlyOwner{
        tokenU = _tokenU;
    }
    function setmaxityPool (address _maxityPool) public onlyOwner{
        maxityPool = _maxityPool;
    }
    function setmaxityBackup(address _maxityBackup) public onlyOwner{
        maxityBackup = _maxityBackup;
    }
    function setLPToken (address _lptoken) public onlyOwner{
        lptoken = _lptoken;
    }
    function setFeeTo (address _feeTo) public onlyOwner{
        feeTo = _feeTo;
    }

    function setWrappedNative (address _wrappedNative) public onlyOwner{
        wrappedNative = _wrappedNative;
    }

   
    function setSweeper (address _sweeper) public onlyOwner{
        sweeper = _sweeper;
    }
    function setRefStore(address _refStore) public onlyOwner{
        refStore = _refStore;
    }

    function setmaxityRefs(address _maxityRefs) public onlyOwner{
        maxityRefs = _maxityRefs;
    }
    function setmaxityProfitShare(address _maxityProfitShare) public onlyOwner{
        maxityProfitShare = _maxityProfitShare;
    }


    //Register user
    function registerUser(address upper,address distributor,bytes memory extdata) external override{
        ReferencesStore(refStore).setUpper(msg.sender, upper,distributor,extdata);
    }

    function setUserExtData(bytes memory extdata) external override{
        ReferencesStore(refStore).setUserExtData(msg.sender,extdata);
    }

    function getUserExtData(address _user) external override view returns(bytes memory){
        ReferencesStore(refStore).getUserExtData(_user);
    }
    //Add new game
    function addGame(address _game) public onlyOwner{
        games[_game] = IGame(_game);
    }

    function swapTokenForUT(address _token,uint256 amountToken,address to) external override returns(uint256 amountU){
        TransferHelper.safeTransferFrom(_token, msg.sender, address(this), amountToken);
        TransferHelper.safeApprove(_token, tokenU, amountToken);
        amountU = UTToken(tokenU).deposit(_token,amountToken,to);
    }

    function swapUTForToken(address _token,uint256 amountU,address to) external override returns(uint256 amountToken){
        TransferHelper.safeTransferFrom(tokenU, msg.sender, address(this), amountU);
        amountToken = UTToken(tokenU).withdraw(_token, amountU, to);
    }

    function addBonusPool(address _token,uint256 amountToken,address to,bool topool) external override returns(uint256 amountU,uint256 liqudity) {

        TransferHelper.safeTransferFrom(_token, msg.sender, address(this), amountToken);
        TransferHelper.safeApprove(_token, tokenU, amountToken);
        amountU = UTToken(tokenU).deposit(_token,amountToken,lptoken);
        // // IMintableToken(tokenU).mint(lptoken,amountU);
        if(topool){
            liqudity = ILPToken(lptoken).mint(address(this));
            uint pid=IMPool(maxityPool).pidFromLPAddr(lptoken);
            TransferHelper.safeApprove(lptoken, maxityPool, liqudity);
            IMPool(maxityPool).deposit(pid,liqudity,to);
        }else{
            liqudity = ILPToken(lptoken).mint(to);
        }
    }

    function removeBonusPool(address _token,uint256 liquidity,address to) external override returns(uint256 amountToken,uint256 amountU) {
        // uint256 decimals = usdTokensDecimal[_token];
        TransferHelper.safeTransferFrom(lptoken, msg.sender, lptoken, liquidity); // send liquidity to lptoken
        amountU = ILPToken(lptoken).burn(address(this));
        amountToken = UTToken(tokenU).withdraw(_token, amountU, to);
    }
    //mint721
    function mintMax721(address _token,address designer, uint [] memory _futureRoyaltys,string []memory tokenURIOrigins,bytes calldata) external override returns (uint[] memory tokenids){
        require (IMaxity721Token(_token).inWhiteList(msg.sender),"Not owner");
        return IMaxity721Token(_token).mint(designer, msg.sender, _futureRoyaltys, tokenURIOrigins);
    }

    //mintAndSellMax721
    function mintAndSellMax721(
        address _market,
        address _token,
        address designer
        ,uint [] memory _futureRoyaltys,string []memory tokenURIOrigins
        ,uint [] memory unit_prices
        ,bytes calldata ) external override returns (uint[] memory tokenids){
        require (IMaxity721Token(_token).inWhiteList(msg.sender),"User is not whitelisted");

        require (_futureRoyaltys.length == unit_prices.length ,"Price length not equal to mint length");

        uint256 [] memory new_tokenids =  IMaxity721Token(_token).mint(designer, _market,_futureRoyaltys, tokenURIOrigins);
        address ngoAddress=IMaxityMetadata(_token).ngowallet();
        IMaxityMarketPlace(_market).sellByFixPrice(_token,new_tokenids,unit_prices,ngoAddress);
        return new_tokenids;
    }

    //mintAndAuctionMax721
    function mintAndAuctionMax721(address _market,address _token,address designer
        ,uint [] memory _futureRoyaltys,string []memory tokenURIOrigins
        ,uint [] memory base_prices,uint [] memory incre_prices,uint [] memory starttimes,uint [] memory deadlines) external override returns (uint[] memory tokenids){
        
        require (IMaxity721Token(_token).inWhiteList(msg.sender),"User is not whitelisted");
        uint count = _futureRoyaltys.length;
        require (count == base_prices.length ,"base_prices length not equal to mint length");
        require (count == incre_prices.length ,"incre_prices length not equal to mint length");
        require (count == starttimes.length ,"starttimes length not equal to mint length");
        require (count == deadlines.length ,"deadlines length not equal to mint length");
        uint256 [] memory new_tokenids =  IMaxity721Token(_token).mint(designer, _market, _futureRoyaltys, tokenURIOrigins);
        address ngoAddress=IMaxityMetadata(_token).ngowallet();
        IMaxityMarketPlace(_market).auctionMax721(_token,new_tokenids,base_prices,incre_prices,starttimes,deadlines,ngoAddress);
        return new_tokenids;
    }

    function buyNative(address _market,address _token,uint256 _tokenid,address token_to,address nativeSweep) public nonReentrant override payable {
        IWMATIC(wrappedNative).deposit{value: msg.value}();

        assert(IWMATIC(wrappedNative).approve(_market, msg.value));
        // uint before_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        IMaxityMarketPlace(_market).buy(_token,_tokenid,token_to);
        uint after_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        if(after_balance>0)
        {
            IWMATIC(wrappedNative).transfer(nativeSweep, after_balance);
        }
    }

    function bidNative(address _market, address _token,uint256 _tokenid,address token_to,address nativeSweep) public nonReentrant override payable {
        IWMATIC(wrappedNative).deposit{value: msg.value}();
        assert(IWMATIC(wrappedNative).approve(_market, msg.value));
        // uint before_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        IMaxityMarketPlace(_market).bid(_token,_tokenid,msg.value,token_to);
        uint after_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        if(after_balance>0)
        {
            IWMATIC(wrappedNative).transfer(nativeSweep, after_balance);
        }
    }
    function auctionOnFixPriceNative(address _market,address _token,uint _tokenid,address token_to,address nativeSweep,uint deadline)public nonReentrant override payable{
        IWMATIC(wrappedNative).deposit{value: msg.value}();

        assert(IWMATIC(wrappedNative).approve(_market, msg.value));
        // uint before_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        IMaxityMarketPlace(_market).auctionOnFixPrice(_token,_tokenid,msg.value,token_to,deadline);
        uint after_balance = IWMATIC(wrappedNative).balanceOf(address(this));
        if(after_balance>0)
        {
            IWMATIC(wrappedNative).transfer(nativeSweep, after_balance);
        }

    }


    function delist(address _market,address _token,uint256 _tokenid) public onlyOwner override{
        IMaxityMarketPlace(_market).delist(_token,_tokenid);
    }
    
    function profitShare(uint256 amountU) external override {
        require(maxityProfitShare!=address(0x0),"maxityProfitShare is zero address");
        TransferHelper.safeTransferFrom(tokenU, msg.sender, maxityProfitShare, amountU);
        IMasterChef(maxityProfitShare).massUpdatePools();
    }


    function userLend(uint256 _pid,uint256 _lendAmount,address _lender) external override {
        require(maxityPool!=address(0x0),"maxityPool is zero address");
        IMPool(maxityPool).userLockFromRouter(msg.sender,_pid,_lendAmount,_lender);
    }
    function userPayFromRouter(address _lender,address _lpToken,uint256 _utAmount) external override {
        require(_lender!=address(0x0),"_lender is zero address");
        if(_utAmount>0){
            TransferHelper.safeTransferFrom(tokenU, msg.sender, _lender, _utAmount);
        }
        ILender(_lender).userPayFromRouter(msg.sender,_lpToken,_utAmount);
    }

    function emergencyWithdraw(address _token) public onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) > 0, "Insufficient contract balance");
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

      // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyNative(uint256 amount) public onlyOwner {
        TransferHelper.safeTransferNative(msg.sender,amount)  ;
    }
}
