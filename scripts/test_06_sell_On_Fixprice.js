
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

  

  let amount=ethers.utils.parseEther('1');
  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint unit_price
  // ,bytes calldata 
  // function sellByFixPrice(address _token,uint256[] memory _tokenids,uint [] memory _prices,address _seller) nonReentrant external  returns (uint) {
    await wmarket.connect(accounts[1]).sellByFixPrice(addrs.mtt,[3],[amount],accounts[1].address);

  const market_logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdOnSale(address,uint256,address,uint256)")]//event TokenIdOnSale(address indexed _token,uint256 indexed _tokenid,address indexed seller,uint256 fixprice);
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
