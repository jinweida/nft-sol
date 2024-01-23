
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const GUTToken = await hre.ethers.getContractFactory("GUTToken");
  const mxt = await GUTToken.deploy("Maxity Token","MXT");
  await mxt.deployed();
  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");
  console.log("mxt deployed to:", mxt.address);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
