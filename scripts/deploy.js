async function main() {
    const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
 
    // Start deployment, returning a promise that resolves to a contract object
    const owners = [process.env.OWNER_ADDRESS]
    const required = 1
    const multisig_wallet = await MultiSigWallet.deploy(owners, required);
    console.log("Contract deployed to address:", multisig_wallet.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });