const { expect } = require('chai');
const { ethers } = require('hardhat');
const { utils } = ethers;

let admin, user1, user2;
let mainFactory,
  factoryRecords,
  tokenFactory,
  accountRules,
  deploySubscriptionService;
const ZERO_ADDRESS = ethers.constants.AddressZero;
const ZERO_BYTES32 = ethers.constants.HashZero;

const accountRulesAddr = hre.accountRulesAddr;

beforeEach(async () => {
  [admin, user1, user2] = await ethers.getSigners();

  hre.tracer.nameTags[admin.address] = 'Admin';
  hre.tracer.nameTags[user1.address] = 'User1';

  const MainFactory = await ethers.getContractFactory('MainFactory');
  mainFactory = await MainFactory.deploy(accountRulesAddr);
  await mainFactory.deployed();

  await mainFactory.deployFactoryRecords();
  const factoryRecordsAddrs = await mainFactory.factoryRecords();
  factoryRecords = await ethers.getContractAt(
    'FactoryRecords',
    factoryRecordsAddrs
  );

  await mainFactory.deploySubscriptionService();
  const deploySubscriptionServiceAddrs =
    await mainFactory.subscriptionService();
  deploySubscriptionService = await ethers.getContractAt(
    'SubscriptionHandler',
    deploySubscriptionServiceAddrs
  );

  accountRules = await ethers.getContractAt(
    'AccountRules',
    hre.accountRulesAddr
  );
});

describe('MainFactory Contract', () => {
  it('Should deploy with admin roles set to FACTORY_ROLE', async () => {
    expect(mainFactory.address).to.be.properAddress;
    expect(
      await mainFactory.hasRole(
        utils.keccak256(utils.toUtf8Bytes('FACTORY_ROLE')),
        admin.address
      )
    ).is.true;
  });

  it('Should deploy a Factory Records contract', async () => {
    expect(factoryRecords.address).to.be.properAddress;
    expect(factoryRecords.address).is.not.equal(ZERO_ADDRESS);
  });

  it('Should deploy a Subscription service contract', async () => {
    expect(deploySubscriptionService.address).to.be.properAddress;
    expect(deploySubscriptionService.address).is.not.equal(ZERO_ADDRESS);
  });

  it('Can deploy token contract and add it to Factory records', async () => {
    await mainFactory.connect(user1).deployToken('TokenName', 'SYM');
    const getContractDeplList = await factoryRecords.getContractDeplList();
    tokenFactory = await ethers.getContractAt(
      'TokenFactory',
      getContractDeplList[0].deplAddr
    );
    expect(getContractDeplList[0].ownerAddr).is.equal(user1.address);
    expect(await tokenFactory.getContractName()).is.equal(
      getContractDeplList[0].deplName
    );
    expect(await tokenFactory.getContractVersion()).is.equal(
      getContractDeplList[0].version
    );
  });

  it('Add deployed contract address in AccountRules permitted accounts', async () => {
    await mainFactory.connect(user1).deployToken('TokenName', 'SYM');
    const getContractDeplList = await factoryRecords.getContractDeplList();
    expect(await accountRules.accountPermitted(getContractDeplList[0].deplAddr))
      .ok;
  });
});
