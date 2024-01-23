
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlace");
  const wmarket = await MaxityMarketPlace.attach(addrs.wmarket);

  console.log("wmarket attach to:", wmarket.address);

  

  let base_price=ethers.utils.parseEther('0.0001');
  let incre_price=ethers.utils.parseEther('0.0001');
  var date=new Date()
  let deadline=date.setDate(date.getDate()+1);//deline to 1 day


  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint unit_price
  // ,bytes calldata 
  //address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin,bytes calldata
  await wmarket.auctionMax721(addrs.mtt,[0,1,2,3],base_price,incre_price,deadline,accounts[0].address);

  const market_logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdOnAuction(address,uint256,address,uint,uint256,uint256)")]//event TokenIdOnSale(address indexed _token,uint256 indexed _tokenid,address indexed seller,uint256 fixprice);
  });
  market_logs.map(log => {
    console.log("market_logs=="+JSON.stringify(log));
  })


  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
