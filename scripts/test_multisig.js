
const { ethers } = require("hardhat");
const hre = require("hardhat");
require("@nomiclabs/hardhat-waffle");

async function main() {


  const addrs =  hre.network.config.attachs;

  const accounts = await ethers.getSigners();

    console.log("accounts[0] =", accounts[0].address);
    console.log("accounts[1] =", accounts[1].address);
    console.log("accounts[2] =", accounts[2].address);

  const MultiSigWallet = await hre.ethers.getContractFactory("MultiSigWallet");
  const msig = await MultiSigWallet.deploy([accounts[0].address,accounts[1].address,accounts[2].address],2);
  await msig.deployed();
  // const msig = await MultiSigWallet.attach("0x8016ad5c83bee6237716c68f096c76eaef348a17");

  console.log("msig.addr="+msig.address);

  //addowner "7065cb48000000000000000000000000"
  //reomve:  "173825d9000000000000000000000000"
  var addOwnerData = "173825d9000000000000000000000000"+accounts[4].address.substring(2);
  console.log("addOwnerData="+addOwnerData);
  //通过签名来提交主链交易

  let txid1 = await msig.submitTransaction(chainCfg.address,0,Buffer.from(addOwnerData,'hex'));

  let transactionID = txid1.raw;
  console.log("msig.txid1="+JSON.stringify(txid1));
  console.log("transactionID="+JSON.stringify(transactionID));


  console.log("account[4] is owner=",await chainCfg.isAddressOwner(accounts[4].address))
  
  let txid2 =await msig.connect(accounts[1]).confirmTransaction(Buffer.from(transactionID.substring(2),'hex'));

  console.log("msig.txid2="+JSON.stringify(txid2));

  console.log("account[4] is owner=",await chainCfg.isAddressOwner(accounts[4].address))
  


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
