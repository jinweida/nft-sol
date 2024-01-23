// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;




interface IMRouter  {
    
    //注册绑定用户
    function registerUser(address upper,address distributor,bytes memory extdata) external ;

    //设置用户的扩展信息,例如邮箱
    function setUserExtData(bytes memory extdata) external ;


    //获取用户扩展数据，例如邮箱
    function getUserExtData(address who) external view returns(bytes memory);
    
    //交换USDT/BUSD/DAI到UT
    function swapTokenForUT(address _token,uint256 amountToken,address to) external returns(uint256 amountU);

    //交换UT到USDT/BUSD/DAI
    function swapUTForToken(address _token,uint256 amountU,address to) external returns(uint256 amountToken);
    
    //添加稳定币到池子，topool是否将流动性直接到BGMPool挖矿
    function addBonusPool(address _token,uint256 amountToken,address to,bool topool) external returns(uint256 amountU,uint256 liqudity) ;

    //从池子里面移出流动性
    function removeBonusPool(address _token,uint256 liquidity,address to) external returns(uint256 amountToken,uint256 amountU);
    

    //mint721
    function mintMax721(address _token,address designer, uint [] memory _futureRoyalty,string []memory tokenURIOrigin,bytes calldata _data) external returns (uint[] memory tokenids);

    //mintAndSellMax721
    function mintAndSellMax721(address _market,  address _token,address designer
        ,uint [] memory _futureRoyalty,string []memory tokenURIOrigin
        ,uint [] memory unit_price
        ,bytes calldata _data) external   returns (uint[] memory tokenids);

    //mintAndAuctionMax721
    function mintAndAuctionMax721(address _market,address _token,address designer
        ,uint [] memory _futureRoyaltys,string []memory tokenURIOrigin
        ,uint [] memory base_prices,uint [] memory incre_prices,uint [] memory starttimes,uint [] memory deadlines) external  returns (uint[] memory tokenids);

    //通过主链币购买
    function buyNative(address _market,address _token,uint256 _tokenid,address token_to,address nativeSweep) external payable ;

    //通过主链币竞价
    function bidNative(address _market,address _token,uint256 _tokenid,address token_to,address nativeSweep) external payable ;

    //下架
    function delist(address _market,address _token,uint256 _tokenid) external ;

    //喊价模式
    function auctionOnFixPriceNative(address _market,address _token,uint _tokenid,address token_to,address nativeSweep,uint deadline)external payable;

    //从池子里借出UT
    function userLend(uint256 _pid,uint256 _lockAmount,address _lender) external ;

    //归还UT给lender    
    function userPayFromRouter(address _lender,address _lpToken,uint256 _utAmount) external;
    
    //利润分配
    function profitShare(uint256 amountU) external;

}
