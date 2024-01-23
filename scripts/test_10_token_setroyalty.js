
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);

  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint unit_price
  // ,bytes calldata 
  //address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin,bytes calldata
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach(addrs.mtt);
  console.log("mtt attached to:", mtt.address);  


  [1,2,3,4,5].forEach((tokenid,idx)=>{
    console.log("set token v="+tokenid+",idx="+idx);

    await mtt.setFutureRoyalty(tokenid,10000000);
    //await mtt["safeTransferFrom(address,address,uint256)"](accounts[0].address,accounts[1].address,2);
  }) 
  //await mtt["safeTransferFrom(address,address,uint256)"](accounts[0].address,accounts[1].address,2);

  

  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
