import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-etherscan';
import "hardhat-gas-reporter"
import 'hardhat-deploy';
import 'hardhat-contract-sizer';
import {HardhatUserConfig} from "hardhat/config";

import dotenv from 'dotenv';
import {join} from "path";

const networkIndex = process.argv.indexOf('--network');
if (networkIndex !== -1) {
    const networkName = process.argv[networkIndex + 1];
    if (networkName === 'mainnet') {
        dotenv.config({path: join(__dirname, '.env')});
    } else {
        dotenv.config({path: join(__dirname, '.env.dev')});
    }
} else {
    dotenv.config({path: join(__dirname, '.env.dev')});
}


const privateKey = process.env.PRIVATE_KEY;
const nodeEndpoint = process.env.NODE_ENDPOINT|| '';
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || '';

if (!privateKey) {
    throw Error('PRIVATE_KEY is required.');
}


const config: HardhatUserConfig = {
    solidity: {
        version: '0.8.9',
        settings: {
            optimizer: {
                enabled: true,
                runs: 1000,
            },
        },
    },
    networks: {
        localhost: {
            url: 'http://127.0.0.1:8545',
        },
        mainnet: {
            url: nodeEndpoint,
        },
        kovan: {
            url: nodeEndpoint,
            accounts: [privateKey],
        },
        goerli: {
            url: nodeEndpoint,
            accounts: [privateKey],
        },
    },
    namedAccounts: {
        deployer: 0,
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
};

export default config;