const Web3 = require('web3')
const web3 = new Web3('https://ropsten.infura.io/v3/9b02a81a69074206bd1e97a7b834b0a2')


// Read the deployed contract - get the addresss from Etherscan
const contractAddress = '0x18ED7bD95C8ad54E09c67C9fB6792B82378cB566'
const contractABI = [{"inputs": [{"internalType": "uint256","name": "a","type": "uint256"},{"internalType": "uint256","name": "b","type": "uint256"}],"name": "add","outputs": [{"internalType": "uint256","name": "","type": "uint256"}],"stateMutability": "nonpayable","type": "function"},{"inputs": [],"name": "result","outputs": [{"internalType": "uint256","name": "","type": "uint256"}],"stateMutability": "view","type": "function"}]

const contract = new web3.eth.Contract(contractABI, contractAddress)


// Check Token balance for account1
contract.methods.add(8,9).call((err, result) => {
  console.log({ err, result})
})
