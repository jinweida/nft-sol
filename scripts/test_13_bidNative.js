
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
const {execSync} = require('child_process');
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address,await ethers.provider.getBalance(account.address));
  }

    
  const MaxityRouter = await hre.ethers.getContractFactory("MaxityRouterV2");  
  const router = await MaxityRouter.attach(addrs.router);

  console.log("router attach to:", router.address);
  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlaceV3");
  const wmarket = await MaxityMarketPlace.attach(addrs.wmarket);

  console.log("wmarket attach to:", wmarket.address);

  

  var date=new Date()
  let deadline=date.setDate(date.getDate()+1);//deline to 1 day
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach(addrs.mtt);
  console.log("mtt attached to:", mtt.address);  

  let amount=ethers.utils.parseEther('20');

  //or approval for all
  await mtt.setApprovalForAll(addrs.wmarket,true);
  console.log("approve for all ok")

  // console.log(await accounts[1])
  await router.bidNative(
    addrs.mtt,
    6,
    accounts[0].address,
    accounts[0].address,
    {value:amount});
    execSync('sleep 3');

  const market_logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("BidOnTokenId(address,uint256,address,uint)")]
  });
  market_logs.map(log => {
    console.log("BidOnTokenId=="+JSON.stringify(log));
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
