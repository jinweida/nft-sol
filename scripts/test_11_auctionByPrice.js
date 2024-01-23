
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
  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlaceV3");
  const wmarket = await MaxityMarketPlace.attach(addrs.wmarket);

  console.log("wmarket attach to:", wmarket.address);

  

  var date=new Date()
  let deadline=date.setDate(date.getDate()+1);//deline to 1 day
  
  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");

  const mtt = await Maxity721Token.attach(addrs.mtt);
  console.log("mtt attached to:", mtt.address);  

  let amount=ethers.utils.parseEther('0.1');

  //or approval for all
  await mtt.connect(accounts[1]).setApprovalForAll(addrs.wmarket,true);
  console.log("approve for all ok")

  console.log(await mtt.ownerOf(1));

  await router.auctionOnFixPriceNative(addrs.mtt,3,accounts[1].address,accounts[1].address,parseInt(deadline/1000),{value:amount});

  
  const market_logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdOnAuctionByPrice(address,uint256,address,uint256,uint,uint256,uint)")]
  });
  market_logs.map(log => {
    console.log("TokenIdOnAuctionByPrice=="+JSON.stringify(log));
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
