
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach(addrs.mtt);
  console.log("mtt attached to:", mtt.address);  

  console.log("mtt ngo is to:",await mtt.ngo());

  console.log("mtt is desiger of 81 is:",await mtt.disigner(81));

  console.log("mtt is futureRoyalty of  81 is :",await mtt.futureRoyalty(81));

  // const mint1=await mtt["mint(address)"](accounts[0].address)

  // console.log("mtt mint.1:",await mtt.);

  
 

  
  // var callPromise = ethers.provider.getLogs(filter);
  // callPromise.then(function(events) {
  //     console.log("Printing array of events:");
  //     console.log(events);
  // }).catch(function(err){
  //     console.log(err);
  // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
