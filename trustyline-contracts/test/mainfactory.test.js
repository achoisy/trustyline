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
    expect(
      await mainFactory.connect(user1).deployToken('TokenName', 'SYM')
    ).to.emit(mainFactory, 'NewTokenDeploy');
    const userDpls = await factoryRecords.getUserDeplList(user1.address);

    expect(userDpls[0]).to.have.lengthOf(3);
    expect(userDpls[0][0]).to.be.properAddress;

    tokenFactory = await ethers.getContractAt('TokenFactory', userDpls[0][0]);
    expect(await tokenFactory.name()).is.equal('TokenName');
    expect(await tokenFactory.symbol()).is.equal('SYM');
  });

  it('Can return a list of contract deployed by user address', async () => {
    await mainFactory.connect(user1).deployToken('TokenName1', 'SYM1');
    await mainFactory.connect(user2).deployToken('TokenName2', 'SYM2');

    // User1 token deployement
    const user1Dpls = await factoryRecords.getUserDeplList(user1.address);
    const user1Token = await ethers.getContractAt(
      'TokenFactory',
      user1Dpls[0][0]
    );

    // User2 token deployement
    const user2Dpls = await factoryRecords.getUserDeplList(user2.address);
    const user2Token = await ethers.getContractAt(
      'TokenFactory',
      user2Dpls[0][0]
    );

    expect(user1Dpls).to.have.lengthOf(1); // Only 1 contract should there !
    expect(await user1Token.name()).is.equal('TokenName1');
    expect(await user1Token.symbol()).is.equal('SYM1');
    expect(await user1Token.getContractName()).is.equal(user1Dpls[0][1]);
    expect(await user1Token.getContractVersion()).is.equal(user1Dpls[0][2]);

    expect(user2Dpls).to.have.lengthOf(1); // Only 1 contract should there !
    expect(await user2Token.name()).is.equal('TokenName2');
    expect(await user2Token.symbol()).is.equal('SYM2');
    expect(await user2Token.getContractName()).is.equal(user2Dpls[0][1]);
    expect(await user2Token.getContractVersion()).is.equal(user2Dpls[0][2]);
  });

  it('Can return a list of deployed contract by contract name (byte32)', async () => {
    await mainFactory.connect(user1).deployToken('TokenName1', 'SYM1');
    await mainFactory.connect(user2).deployToken('TokenName2', 'SYM2');

    const contractDeplList = await factoryRecords.getContractDeplList(
      utils.keccak256(utils.toUtf8Bytes('TOKEN_FACTORY'))
    );

    expect(contractDeplList).to.have.lengthOf(2);
    expect(contractDeplList[0][1]).is.equal(user1.address);
    expect(contractDeplList[1][1]).is.equal(user2.address);
  });

  it('Add deployed contract address in AccountRules permitted accounts', async () => {
    await mainFactory.connect(user1).deployToken('TokenName', 'SYM');
    const userDpls = await factoryRecords.getUserDeplList(user1.address);
    const dplsAddr = userDpls[0][0];
    expect(await accountRules.accountPermitted(dplsAddr)).ok;
  });
});
