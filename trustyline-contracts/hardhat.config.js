require('dotenv').config();
const { subtask } = require('hardhat/config');
const {
  TASK_TEST_SETUP_TEST_ENVIRONMENT,
} = require('hardhat/builtin-tasks/task-names');
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require('hardhat-tracer');
require('@atixlabs/hardhat-time-n-mine');
require('hardhat-erc1820');
require('hardhat-deploy');

async function ensureAccountRules(hre) {
  const AccountRules = await hre.ethers.getContractFactory('AccountRules');
  const accountRules = await AccountRules.deploy();
  await accountRules.deployed();

  hre.accountRulesAddr = accountRules.address;

  console.log(`AccountRules deployed at ${accountRules.address}`);
}

async function deployENS(hre) {
  const ENSFactory = await hre.ethers.getContractFactory('ENSCustomRegistry');
  const ENSContract = await ENSFactory.deploy();
  await ENSContract.deployed();

  console.log(`ENS Registry deployed at ${ENSContract.address}`);

  const _OwnedResolver = await hre.ethers.getContractFactory('OwnedResolver');
  const OwnedResolver = await _OwnedResolver.deploy();
  await OwnedResolver.deployed();

  console.log(`ENS Resolver deployed at ${OwnedResolver.address}`);

  hre.ENS = {
    Registry: ENSContract.address,
    Resolver: OwnedResolver.address,
  };
}

subtask(TASK_TEST_SETUP_TEST_ENVIRONMENT).setAction(
  async (args, hre, runSuper) => {
    await runSuper(args);
    await ensureAccountRules(hre);
    await deployENS(hre);
  }
);

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    trustyline: {
      url: 'https://jsonrpc.trustyline.com',
      chainId: 1337,
      accounts: [`${process.env.TRUSTYLINE_DEPLOYER_PRIV_KEY}`],
      live: true,
      saveDeployments: true,
      tags: ['live-testnet'],
    },
    ganache: {
      url: 'HTTP://0.0.0.0:7545',
      chainId: 1337,
      live: true,
      saveDeployments: true,
      tags: ['ganache'],
      accounts: {
        mnemonic:
          'stomach twice feature north ribbon normal easily extend lift wet truck school',
      },
    },
  },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
