const Web3 = require('web3')
const rpcURL = 'https://ropsten.infura.io/v3/9b02a81a69074206bd1e97a7b834b0a2' // Your RPC URL goes here
const web3 = new Web3(rpcURL)
const address = '0x9b64Ec623E24d67dB5C5a38AE93BE98a873bD731' // Your account address goes here
web3.eth.getBalance(address, (err, wei) => {
  balance = web3.utils.fromWei(wei, 'ether')
  console.log(balance)
})