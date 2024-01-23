
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityRouter = await hre.ethers.getContractFactory("MaxityRouterV2");
  
  
  const router = await MaxityRouter.deploy(addrs.wmatic);
  await router.deployed();
  console.log("router deployed to:", router.address);
  // await router.setFeeTo(addrs.fee);
  // await router.setMarket(addrs.wmarket);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
