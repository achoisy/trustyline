const { expect } = require('chai');
const { ethers } = require('hardhat');
const { utils } = ethers;

let owner, user1, user2;
let tokenFactory, privacy;
const ZERO_ADDRESS = ethers.constants.AddressZero;
const ZERO_BYTES32 = ethers.constants.HashZero;

beforeEach(async () => {
  [owner, user1, user2] = await ethers.getSigners();

  hre.tracer.nameTags[owner.address] = 'Owner';
  hre.tracer.nameTags[user1.address] = 'User1';

  const TokenFactory = await ethers.getContractFactory('TokenFactory');
  tokenFactory = await TokenFactory.deploy(
    owner.address,
    'TokenName',
    'SYM',
    []
  );
  await tokenFactory.deployed();
});

describe('Token ERC777', () => {
  it('Should deploy a ERC777 Token contract', async () => {
    expect(tokenFactory.address).to.be.properAddress;
  });

  it('Allow the owner to mint some token', async () => {
    await tokenFactory.mint(1000);
    expect(await tokenFactory.totalSupply()).is.equal(1000);
    expect(await tokenFactory.balanceOf(owner.address)).is.equal(1000);
    await expect(tokenFactory.connect(user1).mint(1000)).to.be.reverted;
  });

  it('Can allow acces to only selected user', async () => {
    await tokenFactory.mint(1000);

    await tokenFactory.send(user1.address, 100, ZERO_BYTES32);
    expect(await tokenFactory.balanceOf(user1.address)).is.equal(100);

    await expect(
      tokenFactory.connect(user1).send(owner.address, 100, ZERO_BYTES32)
    ).to.be.revertedWith('Sorry, this contract is private');
  });

  it('Can add user to private users list to allow access to token', async () => {
    await tokenFactory.mint(1000);
    await tokenFactory.send(user1.address, 100, ZERO_BYTES32);

    await expect(
      tokenFactory.connect(user1).send(owner.address, 100, ZERO_BYTES32)
    ).to.be.revertedWith('Sorry, this contract is private');
    await tokenFactory.addUser(user1.address);

    expect(
      await tokenFactory.connect(user1).send(owner.address, 100, ZERO_BYTES32)
    ).ok;
  });

  it('Can delete user from users list to disallow access to token', async () => {
    await tokenFactory.mint(1000);
    await tokenFactory.addUser(user1.address);
    await tokenFactory.send(user1.address, 100, ZERO_BYTES32);

    expect(
      await tokenFactory.connect(user1).send(owner.address, 50, ZERO_BYTES32)
    ).ok;

    await tokenFactory.removeUserByIndex(1);

    await expect(
      tokenFactory.connect(user1).send(owner.address, 50, ZERO_BYTES32)
    ).to.be.revertedWith('Sorry, this contract is private');
  });

  it('Can set token to pulic mode', async () => {
    await tokenFactory.mint(1000);
    await tokenFactory.send(user1.address, 100, ZERO_BYTES32);

    await expect(
      tokenFactory.connect(user1).send(owner.address, 50, ZERO_BYTES32)
    ).to.be.revertedWith('Sorry, this contract is private');

    await tokenFactory.setPublic(true);

    expect(
      await tokenFactory.connect(user1).send(owner.address, 50, ZERO_BYTES32)
    ).ok;
  });
});
