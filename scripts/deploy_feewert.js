
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  const GUTToken = await hre.ethers.getContractFactory("GUTToken");
  const tokenA = await GUTToken.attach(addrs.gut);
  console.log("tokenA attach to:", tokenA.address);


  console.log("deploy.account.addr="+accounts[0].address);
  const WertFeeCollector = await hre.ethers.getContractFactory("WertFeeCollector");//100000
  const wertFee = await WertFeeCollector.deploy();
  await wertFee.deployed();
  console.log("wertFee deployed to:", wertFee.address);

  await wertFee.addAllocReceiver(accounts[0].address,50);
  await wertFee.addAllocReceiver(accounts[1].address,50);
  await wertFee.addBonusInfo(tokenA.address,false);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
