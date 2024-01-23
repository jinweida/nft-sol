
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

  console.log("deploy.account.addr="+accounts[0].address);

  const GUTToken = await hre.ethers.getContractFactory("GUTToken");
  const gut = await GUTToken.deploy("gut","gut");
  await gut.deployed();
  console.log("GUTToken deployed to:", gut.address);

  const MaxityRouter = await hre.ethers.getContractFactory("MaxityRouter");//100000
  const router = await MaxityRouter.deploy();
  await router.deployed();
  console.log("MaxityRouter deployed to:", router.address);

//   constructor(string memory name,string memory symbol,address _ngo,address _ngowallet,string memory _did) ERC721(name, symbol) {

  const Maxity721Token = await hre.ethers.getContractFactory("Maxity721Token");//100000
  const token = await Maxity721Token.deploy("ngo-one","ngo","0x7816752C94C337Ce913fEB7f6f0ee16578813392","0x7816752C94C337Ce913fEB7f6f0ee16578813392","20000");
  await token.deployed();
  console.log("Maxity721Token deployed to:", token.address);

  
  const MaxityMarketPlace = await hre.ethers.getContractFactory("MaxityMarketPlace");//100000
  const market = await MaxityMarketPlace.deploy(gut.address,addrs.freeto,"10000");
  await market.deployed();
  console.log("MaxityMarketPlace deployed to:", market.address);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
