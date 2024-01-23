
const { ethers } = require("hardhat");
const hre = require("hardhat");



async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  // console.log("deploy.account.addr="+accounts[1].address);
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach("0x4be5a67eeec380cbd440bc4207ea87af3d5ce956");
  console.log("mtt attached to:", mtt.address);  

  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xb0de10d35d40257e20a1b60d2c457df690854103"));
  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xc2db37F20Be7F42d23ec262959F4cE0044eAFbd9"));
  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xefd7FFB2c0E8EBCF345845F5b0716538C3aCc0aA"));

  // console.log(await mtt.getWhiteListLength());
  // console.log(await mtt.tokenURI(4))
//   console.log(await mtt.ownerOf(4))
// console.log(await mtt.disigner(4))
console.log(await mtt.tokenURI(4));
//   token address 
// 0xc188A387D32E4CB028545dC26cdA2170e841Edce

// Tokenid 
// 15


  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
