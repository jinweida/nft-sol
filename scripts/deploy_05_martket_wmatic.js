
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlaceV3");
  
  
  const mmarket = await MaxityMarketPlace.deploy(addrs.wmatic,addrs.fee,"0x9379A9ddA4da7edCA2c641933D254d57d83a8B2D");
  await mmarket.deployed();
  console.log("mmarket deployed to:", mmarket.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
