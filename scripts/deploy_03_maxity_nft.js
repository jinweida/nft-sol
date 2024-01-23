
const { ethers } = require("hardhat");
const hre = require("hardhat");



async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");
  const mtt = await Maxity721Token.deploy("Maxity721Token","MTT",addrs.ngo,addrs.ngowallet,"Maxity");
  await mtt.deployed();
  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");
  console.log("mtt deployed to:", mtt.address);

  await mtt.addWhiteList(accounts[0].address);

  console.log("mtt is whitelist to:",await mtt.inWhiteList(accounts[0].address));

  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
