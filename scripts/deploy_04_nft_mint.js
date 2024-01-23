
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

  console.log("mtt is whitelist to:",await mtt.inWhiteList(accounts[0].address));

  // const mint1=await mtt["mint(address)"](accounts[0].address)

  // console.log("mtt mint.1:",await mtt.);


  const mint2 = await mtt["mint(address,address,uint256[],string[])"](accounts[0].address,accounts[0].address,[10],["http://maxity.io"]);
  const res = await mint2.wait();
  console.log(res)

  const logs = await ethers.provider.getLogs({
    address:mtt.address,
    topics: [ethers.utils.id("TokenMint(uint256,address,address,string)")]
  });
  
  const decoder = new ethers.utils.AbiCoder();
  logs.map(log => {
    // console.log("log=="+JSON.stringify(log));
    var uri = decoder.decode(["string"],log.data);
    var tokenid = decoder.decode(["uint256"],log.topics[1]);
    var designer = decoder.decode(["address"],log.topics[2]);
    var to = decoder.decode(["address"],log.topics[3]);
    console.log("minted:tokenid="+tokenid+",designer="+designer+",to="+to+",uri="+uri);
  
  })


  
 

  
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
