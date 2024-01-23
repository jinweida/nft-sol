
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr= "+accounts[0].address);


  const MaxitNGO = await hre.ethers.getContractFactory("MaxitNGO");
  const mxngo = await MaxitNGO.deploy("ngo","29e3D2F908e3bfaeE1aB1BFAAFC30c3C401B5C7A");//,{nonce:0});
  await mxngo.deployed();
  console.log(mxngo)

  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");
  console.log("mxngo deployed to:", mxngo.address);
  //0x5A98898A9df72678D092256470e604E9576AbE9a


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
