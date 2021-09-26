var Tx     = require('ethereumjs-tx').Transaction
const Web3 = require('web3')
const web3 = new Web3('https://ropsten.infura.io/v3/9b02a81a69074206bd1e97a7b834b0a2')

const account1 = '0x9b64Ec623E24d67dB5C5a38AE93BE98a873bD731' // account address 1
const account2 = '0x25b3C00CE5030ABDBCb4B521F5ac67B4176E1097' // account address 2

const privateKey1 = Buffer.from('7c05a6d12d3e77f1d8b4463a5ca16d23991dc3946868d5ef9060181212af8e0f', 'hex')
const privateKey2 = Buffer.from('2d777080cb6a92f3bc6f2c632c726e79f36c807b5a8a9b07b9799ff65393b66a', 'hex')


web3.eth.getTransactionCount(account1, (err, txCount) => {
  // Build the transaction
  const txObject = {
    nonce:    web3.utils.toHex(txCount),
    to:       account2,
    value:    web3.utils.toHex(web3.utils.toWei('0.1', 'ether')),
    gasLimit: web3.utils.toHex(201000),
    gasPrice: web3.utils.toHex(web3.utils.toWei('10', 'gwei'))
  }

  // Sign the transaction
  const tx = new Tx(txObject, {chain:'ropsten', hardfork: 'petersburg'})
  tx.sign(privateKey1)

  const serializedTx = tx.serialize()
  const raw = '0x' + serializedTx.toString('hex')

  // Broadcast the transaction
  web3.eth.sendSignedTransaction(raw, (err, txHash) => {
    console.log('error: ', err)  
    console.log('txHash:', txHash)
    // Now go check etherscan to see the transaction!
  })
})