
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

  

  let base_price=ethers.utils.parseEther('10');
  let incre_price=ethers.utils.parseEther('1');
  var date=new Date()
  let starttimes=date.setDate(date.getDate());
  let deadline=date.setDate(date.getDate()+2);//deline to 1 day

  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint base_price,uint incre_price,uint deadline
  // ,bytes calldata _calldata
  
  await router.mintAndAuctionMax721(
    addrs.mtt,
    accounts[0].address,
    [10],
    ["http://maxity.io"],
    [base_price],
    [incre_price],
    [parseInt(starttimes/1000)],
    [parseInt(deadline/1000)],
    "0x");

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


  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
