
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityMarketPlaceV2 = await hre.ethers.getContractFactory("MaxityMarketPlaceV2");
  
  
  const mmarketv2 = await MaxityMarketPlaceV2.deploy(addrs.wmatic,addrs.fee,addrs.wmarket1);
  await mmarketv2.deployed();
  console.log("mmarketv2 deployed to:", mmarketv2.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
