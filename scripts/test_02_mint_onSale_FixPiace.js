
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityRouter = await hre.ethers.getContractFactory("MaxityRouterV2");  
  const router = await MaxityRouter.attach(addrs.router);

  console.log("router attach to:", router.address);

  

  let amount=ethers.utils.parseEther('1');
  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint unit_price
  // ,bytes calldata 
  //address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin,bytes calldata
  let result=await router.mintAndSellMax721(addrs.mtt,accounts[0].address,[10],["http://maxity.io"],[amount],"0x");
console.log(result)
  const logs = await ethers.provider.getLogs({
    address:addrs.mtt,
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

  const market_logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdOnSale(address,uint256,address,uint256)")]//event TokenIdOnSale(address indexed _token,uint256 indexed _tokenid,address indexed seller,uint256 fixprice);
  });
  market_logs.map(log => {
    console.log("market_logs=="+JSON.stringify(log));
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
