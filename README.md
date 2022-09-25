# multisig
Simple ethereum based multisig wallet

## Dev Env Setup
Install node package dependencies
```bash
npm install
```

Create `.env` file containing the following envvars
```bash
API_URL=<app api url from alchemy for example>
PRIVATE_KEY=<your eth account private key>
OWNER_ADDRESS=<your eth account address>
```

## Contract Deployment
```
npx hardhat run scripts/deploy.js --network goerli
```
