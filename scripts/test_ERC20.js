
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();



  filter = {
    // address: "dai.tokens.ethers.eth",
    // fromBlock: await ethers.provider.getBlockNumber(),
    topics: [
        // utils.id("Transfer(address,address,uint256)")
        ]
    }
  // ethers.provider.on(filter, (log, event) => {
        // console.log("get log:"+JSON.stringify(log.data))
    // Emitted whenever a DAI token transfer occurs
  // })

  console.log("deploy account: " + accounts[0].address);
  const GUTToken = await hre.ethers.getContractFactory("GUTToken");
  // const tokenA = await GUTToken.deploy("GUTToken","GUT");
  // await tokenA.deployed();
  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");
  // console.log("tokenA deployed to:", tokenA.address);
  // await tokenA.addMinter(accounts[0].address);
  
  const tokenA = await GUTToken.attach(addrs.gut);
  console.log("tokenA attach to:", tokenA.address);
  
  console.log("tokenA balance is:",await tokenA.balanceOf(accounts[0].address));

  let amount=ethers.utils.parseEther('2000');
  let mintret = await tokenA.mint(accounts[0].address,amount);

  
  console.log("tokenA balance is:",await tokenA.balanceOf(accounts[0].address));


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
