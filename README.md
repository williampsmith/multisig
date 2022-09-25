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
API_KEY=<app api key from alchemy for example>
PRIVATE_KEY=<your eth account private key>
OWNER_ADDRESS=<your eth account address>
```

## Contract Deployment
```
npx hardhat run scripts/deploy.js --network goerli
```

## Interacting with the smart contract
* Add CONTRACT_ADDRESS envvar to `.env` file that points to a contract address (see `Contract Deployment` section above or `contracts.md` for currently deployed addresses on Goerli)
* (edit `scripts/interact.js` as required)
* Run `npx hardhat run scripts/interact.js`