var Tx     = require('ethereumjs-tx').Transaction
const Web3 = require('web3')
const web3 = new Web3('https://ropsten.infura.io/v3/9b02a81a69074206bd1e97a7b834b0a2')

const account1 = '0x9b64Ec623E24d67dB5C5a38AE93BE98a873bD731' // account address 1
const account2 = '0x25b3C00CE5030ABDBCb4B521F5ac67B4176E1097' // account address 2

const privateKey1 = Buffer.from('private key 1', 'hex')
const privateKey2 = Buffer.from('private key 2', 'hex')


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
