
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
// web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));
async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);
  
  const MaxityRouter = await hre.ethers.getContractFactory("MaxityRouter");  
  const router = await MaxityRouter.attach(addrs.router);

  console.log("router attach to:", router.address);

  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlace");
  const wmarket = await MaxityMarketPlace.attach(addrs.wmarket);

  console.log("wmarket attach to:", wmarket.address);

  let amount=ethers.utils.parseEther('1');
  const WMATIC = await hre.ethers.getContractFactory("WMATIC");
  const wmatic = await WMATIC.attach(addrs.wmatic);
  console.log("wmatic deployed to:", wmatic.address);
  await wmatic.approve(wmarket.address,amount)
  // const tokenA = await TestERC20.attach("0xf1f3068450e3dd1c20a2997945fadab4f0614f8b");


  // address _token,address designer, uint256 count,uint _futureRoyalty,string memory tokenURIOrigin
  // ,uint base_price,uint incre_price,uint deadline
  // ,bytes calldata _calldata
  
  // function buyNative(address _token,uint256 _tokenid,address token_to,address nativeSweep) public nonReentrant override payable {

  await router.buyNative(addrs.mtt,6,accounts[0].address,"0x0000000000000000000000000000000000000000",{value:amount});

  const logs = await ethers.provider.getLogs({
    address:addrs.wmarket,
    topics: [ethers.utils.id("TokenIdSaled(address,uint256,address,address,uint256)")]
  });
  
  const decoder = new ethers.utils.AbiCoder();
  logs.map(log => {
    console.log("buy.log=="+JSON.stringify(log));
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
