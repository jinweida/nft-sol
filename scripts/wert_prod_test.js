
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  const WertImpl = await hre.ethers.getContractFactory("WertImpl");//100000
  // const wert = await WertImpl.deploy(addrs.wertfee,200,10000);
  // await wert.deployed();
  // console.log("WertImpl deployed to:", wert.address);

  const wert = await WertImpl.attach(addrs.wert);
  console.log("WertImpl attach to:", wert.address);
  
  
  let amount=ethers.utils.parseEther('100');
  const GUTToken = await hre.ethers.getContractFactory("GUTToken");
  const tokenA = await GUTToken.attach(addrs.gut);
  console.log("tokenA attach to:", tokenA.address);

  console.log("tokenA balance is:",await tokenA.balanceOf(accounts[0].address));

  await tokenA.approve(wert.address,amount);
  console.log("apppove ok");

  await tokenA.approve(wert.address,amount);
  console.log("apppove ok");

  await tokenA.approve(wert.address,amount);
  console.log("apppove ok");

  await wert.deposit(addrs.gut,"0xfDaB0739CbB575924cBd24B1339C3BF646747817",amount,1687688350);
  // console.log("TrustVM.parallel to:"+await tvm.parallel());
  //7e931af3a0886a6460dba4b5dc129361a7a8c3363c821d83f4118493818f3bf4

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
