const { subtask } = require('hardhat/config');
const {
  TASK_TEST_SETUP_TEST_ENVIRONMENT,
} = require('hardhat/builtin-tasks/task-names');
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require('hardhat-tracer');
require('@atixlabs/hardhat-time-n-mine');
require('hardhat-erc1820');

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
      allowUnlimitedContractSize: true,
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
};
