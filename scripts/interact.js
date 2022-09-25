const API_KEY = process.env.API_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS

const contract = require("../artifacts/contracts/multisig_wallet.sol/MultiSigWallet.json")

// optionally print out the ABI (other args are for pretty print)
// console.log(`ABI: ${JSON.stringify(contract.abi, null, 2)}`)

// node provider that gives us read and write access to the blockchain.
const alchemyProvider = new ethers.providers.AlchemyProvider(network="goerli", API_KEY)
// represents an Ethereum account that has the ability to sign transactions.
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider)
// Ethers.js object that represents a specific contract deployed on-chain.
const multiSigWalletContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer)

async function main() {
    // read op
    const owner = await multiSigWalletContract.owners(0)
    console.log("The first owner (contract owner) is: " + owner);

    // write op example
    // console.log("Updating the message...");
    // const tx = await helloWorldContract.update("This is the new message.");
    // await tx.wait();
}
main();