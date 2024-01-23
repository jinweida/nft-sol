
const { ethers } = require("hardhat");
const hre = require("hardhat");



async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlace");

  const mtt = await MaxityMarketPlace.attach("0xae3F29b8782DB1132aD8D4505075830f96E584b2");
  console.log("mtt attached to:", mtt.address);  

  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xb0de10d35d40257e20a1b60d2c457df690854103"));
  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xc2db37F20Be7F42d23ec262959F4cE0044eAFbd9"));
  // console.log("mtt is whitelist to:",await mtt.inWhiteList("0xefd7FFB2c0E8EBCF345845F5b0716538C3aCc0aA"));

  // console.log(await mtt.getWhiteListLength());
  // console.log(await mtt.tokenURI(4))
  // console.log(await mtt.ownerOf(4))

//   token address 
// 0xc188A387D32E4CB028545dC26cdA2170e841Edce

console.log(await mtt.marketUnits("0x7138c235AFd7F38cE7224CEd2C2D80e2ea5ea490",3))
console.log(await mtt.soldCount("0x7138c235AFd7F38cE7224CEd2C2D80e2ea5ea490",3))

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
