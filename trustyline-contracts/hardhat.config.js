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

subtask(TASK_TEST_SETUP_TEST_ENVIRONMENT).setAction(
  async (args, hre, runSuper) => {
    await runSuper(args);
    await ensureAccountRules(hre);
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
