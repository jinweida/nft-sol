
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const WMATIC = await hre.ethers.getContractFactory("WMATIC");
  const wmatic = await WMATIC.deploy();
  await wmatic.deployed();
  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");
  console.log("wmatic deployed to:", wmatic.address);

  let amount=ethers.utils.parseEther('200');

  await wmatic.deposit({value:amount});
  
  console.log("balance="+await wmatic.balanceOf(accounts[0].address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
