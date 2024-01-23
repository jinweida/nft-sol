
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);  

  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlace");
  const wmarket = await MaxityMarketPlace.attach(addrs.wmarket);

  console.log("wmarket attach to:", wmarket.address);

  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint base_price,uint incre_price,uint deadline
  // ,bytes calldata _calldata
  
  await wmarket.delist(addrs.mtt,32);

  const logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdDelist(address,uint256,address)")]
  });
  
  const decoder = new ethers.utils.AbiCoder();
  logs.map(log => {
    console.log("delist.log=="+JSON.stringify(log));
    // var uri = decoder.decode(["string"],log.data);
    // var tokenid = decoder.decode(["uint256"],log.topics[1]);
    // var designer = decoder.decode(["address"],log.topics[2]);
    // var to = decoder.decode(["address"],log.topics[3]);
    // console.log("minted:tokenid="+tokenid+",designer="+designer+",to="+to+",uri="+uri);
  })
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
