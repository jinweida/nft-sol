
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
const  abi=require('ethereumjs-abi')

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log(ethers.utils.parseEther('100').toBigInt())
  let encoded=abi.simpleEncode("deposit(address,address,uint,uint)","0x64E5dee8896eabB7C2dD66cF337Afa5a956f42C5","0x7816752C94C337Ce913fEB7f6f0ee16578813392",ethers.utils.parseEther('100').toBigInt(),1687688350);
  console.log(Buffer.from(encoded).toString("hex"));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
