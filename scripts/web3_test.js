
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");
web3 = new Web3(new Web3.providers.HttpProvider(hre.network.config.url));

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
//   ethers.provider.on(filter, (log, event) => {
//         console.log("get log:"+JSON.stringify(log.data))
//     // Emitted whenever a DAI token transfer occurs
//   })

    console.log("web3.version="+web3.version);
    var jsonFile = "./contracts/abi/UniswapV2Pair.json";
    var abi = JSON.parse(fs.readFileSync(jsonFile));

    var slp1 = new web3.eth.Contract(abi, "0x9cD028B1287803250B1e226F0180EB725428d069");
    var slp2 = new web3.eth.Contract(abi, "0xd07D430Db20d2D7E0c4C11759256adBCC355B20C");



    let pair1_0 = await slp1.methods.token0().call({from:accounts[0].address});
    console.log("pair0="+pair1_0);
    let pair2_0 = await slp2.methods.token0().call({from:accounts[0].address});
    console.log("pair0="+pair2_0);

    let reserves1 = await slp1.methods.getReserves().call({from:accounts[0].address});
    console.log("reserves1="+JSON.stringify(reserves1));

    let reserves2 = await slp2.methods.getReserves().call({from:accounts[0].address});
    console.log("reserves2="+JSON.stringify(reserves2));

    let price1 = reserves1._reserve0/ reserves1._reserve1;
    let price2 = reserves2._reserve0/ reserves2._reserve1;
    
    console.log("prices:"+price1+"==>"+price2);
    
    // const FetchReserves = await hre.ethers.getContractFactory("FetchReserves");
    // const fetch = await FetchReserves.deploy();
    // await fetch.deployed();
    // const lp = await UniswapV2Pair.attach("0xa2D81bEdf22201A77044CDF3Ab4d9dC1FfBc391B");
    // console.log("reservers:"+await lp.getReserves());


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
