
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);

    
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
  console.log(await mtt.tokenURI(109))

  // console.log(await ethers.provider.getBalance(addrs.wmarket))

  // console.log(await wmarket.marketUnits(addrs.mtt,7))
// console.log(await wmarket.feeTo());
  // console.log(await wmarket.marketUnits(mtt.address,106))

  // console.log(await mtt.ownerOf(3));
  // console.log(accounts[1].address);

  // const WMATIC = await hre.ethers.getContractFactory("WMATIC");
  // const wmatic = await WMATIC.attach(addrs.wmatic);
  // console.log("wmatic deployed to:", wmatic.address);

  
  // console.log("balance="+await wmatic.balanceOf(addrs.wmarket));
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
