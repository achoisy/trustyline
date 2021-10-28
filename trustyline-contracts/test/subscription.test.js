const { expect } = require('chai');
const { ethers } = require('hardhat');
const { utils } = ethers;
const hre = require('hardhat');

let subscribe;
let owner;
let user1;

beforeEach(async () => {
  [owner, user1] = await ethers.getSigners();
  const Subscribe = await ethers.getContractFactory('SubscriptionHandler');
  subscribe = await Subscribe.deploy();
  await subscribe.deployed();
});

describe('Subcription Contract', () => {
  it('Should deploy with owner roles set to SUBS_ROLE', async () => {
    expect(subscribe.address).exist;
    expect(
      await subscribe.hasRole(
        utils.keccak256(utils.toUtf8Bytes('SUBS_ROLE')),
        owner.address
      )
    ).is.true;
  });

  it('Can set a time subcription', async () => {
    await subscribe.setSubscription(user1.address, 2, 60);
    // const subscription = await subscribe.getSubscription(user1.address);
    expect(await subscribe.getSubscription(user1.address))
      .to.be.an('array')
      .that.includes(2);
  });

  it('Can check if subscription level is ok', async () => {
    await subscribe.setSubscription(user1.address, 2, 10);
    expect(await subscribe.connect(user1).checkSubscription(user1.address, 1))
      .is.true;
    expect(await subscribe.connect(user1).checkSubscription(user1.address, 3))
      .is.false;
  });

  it('Can check if subscription endtime is ok', async function () {
    await subscribe.setSubscription(user1.address, 2, 5);
    expect(await subscribe.connect(user1).checkSubscription(user1.address, 1))
      .is.true;

    await hre.timeAndMine.increaseTime(10);
    await hre.timeAndMine.mine(1);

    expect(await subscribe.connect(user1).checkSubscription(user1.address, 1))
      .is.false;
  });
});
