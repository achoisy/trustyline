const { expect } = require('chai');
const { ethers } = require('hardhat');

let accountRules;
let admin, user1;

beforeEach(async () => {
  [admin, user1] = await ethers.getSigners();

  accountRules = await ethers.getContractAt(
    'AccountRules',
    hre.accountRulesAddr
  );
});

describe('AccountRules', () => {
  it('Can add a contract to permission rules', async () => {
    expect(await accountRules.addAccount(user1.address)).ok;
    expect(await accountRules.accountPermitted(user1.address)).is.equal(true);
    await accountRules.removeAccount(user1.address);
    expect(await accountRules.accountPermitted(user1.address)).is.equal(false);
  });
});
