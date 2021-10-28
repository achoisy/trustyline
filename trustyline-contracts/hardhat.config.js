require('@nomiclabs/hardhat-waffle');
require('hardhat-tracer');
require('@atixlabs/hardhat-time-n-mine');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
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
