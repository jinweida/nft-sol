import abi from './abi.json'
import { addrs } from './config'
import BigNumber from 'bignumber.js'
const { abi: erc20ABI } = require('./erc20.json')
const Web3 = window.Web3
export const web3 = new Web3(window.ethereum)
export const eth = web3.eth
window.eth = eth
window.web3 = web3
export const Contract = eth.Contract
let address = {
  value: ''
}
eth.getAccounts().then(res => {
  if (!res.length) {
    eth.requestAccounts().then(res => {
      address.value = res[0]
    })
  } else {
    address.value = res[0]
  }
})
export function createERC20Contract (symbolAddress) {
  return new eth.Contract(erc20ABI, symbolAddress)
}

export function mintMax721 () {
  let contract = new Contract(abi, addrs.router)
  return contract.methods.mintMax721(addrs.mtt, address.value, 10, 100, "http://maxity.io", "0x").send({
    from: address.value
  })
}

export function mintAndSellMax721 () {
  let contract = new Contract(abi, addrs.router)
  let amount = web3.utils.toWei('1', 'ether')
  return contract.methods.mintAndSellMax721(addrs.mtt,address.value,10,100,"http://maxity.io",amount,"0x").send({
    from: address.value
  })
}

export function mintAndAuctionMax721 () {
  const base_price = web3.utils.toWei('1', 'ether')
  const incre_price = web3.utils.toWei('10', 'ether')
  let date = new Date()
  let deadline = date.setDate(date.getDate()+1);//deline to 1 day
  let contract = new Contract(abi, addrs.router)
  return contract.methods.mintAndAuctionMax721(addrs.mtt,address.value, 5, 100, "http://maxity.io", base_price, incre_price, deadline,"0x").send({
    from: address.value
  })
}

export function buyNative () {
  let amount = web3.utils.toWei('1', 'ether')
  let contract = new Contract(abi, addrs.router)
  return contract.methods.buyNative(addrs.mtt, 22, address.value, '0x0000000000000000000000000000000000000000').send({
    from: address.value,
    value: amount
  })
}
// await router.delist(addrs.mtt,32);
export function delist () {
  let amount = web3.utils.toWei('1', 'ether')
  let contract = new Contract(abi, addrs.router)
  return contract.methods.delist(addrs.mtt, 22).call()
}