
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
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach(addrs.mtt);
  console.log("mtt attached to:", mtt.address);  

  let amount=ethers.utils.parseEther('1');
  // approve one bye one 
  // await mtt.approve(addrs.wmarket,0);
  // await mtt.approve(addrs.wmarket,1);
  // await mtt.approve(addrs.wmarket,2);

  //or approval for all
  await mtt.connect(accounts[1]).setApprovalForAll(addrs.wmarket,true);
  console.log("approve for all ok")

  await wmarket.connect(accounts[1]).sellByFixPrice(addrs.mtt,[6],[amount],accounts[1].address);

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
