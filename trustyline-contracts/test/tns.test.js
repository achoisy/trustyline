const { expect } = require('chai');
const { ethers } = require('hardhat');
const { utils } = ethers;

let tns;
let owner;
let user1;

const node = utils.keccak256(utils.toUtf8Bytes('0033612345678'));

beforeEach(async () => {
  [owner, user1] = await ethers.getSigners();
  const TNS = await ethers.getContractFactory('TNS');
  tns = await TNS.deploy(owner.address);
  await tns.deployed();
});

describe('Trutyline Number Resolver [TNS]', () => {
  it('Should deploy with owner roles set to TNS_ROLE', async () => {
    expect(tns.address).exist;
    expect(
      await tns.hasRole(
        utils.keccak256(utils.toUtf8Bytes('TNS_ROLE')),
        owner.address
      )
    ).is.true;
  });

  it('Allows to add a number => address and resolve it', async () => {
    await tns.addRecord(node, user1.address);
    expect(await tns.connect(user1).getAddr(node)).is.equal(user1.address);
  });

  it('Only allow user with TNS_ROLE to add a record', async () => {
    try {
      await tns.connect(user1).addRecord(node, user1.address);
      expect(false);
    } catch (error) {
      expect(true);
    }
  });

  it('Can block number resolve', async () => {
    await tns.addRecord(node, user1.address);
    expect(await tns.connect(user1).getAddr(node)).is.equal(user1.address);
    await tns.setLock(node, true);
    try {
      await tns.connect(user1).getAddr(node);
      expect(false);
    } catch (error) {
      expect(true);
    }
  });

  it('Can delete record number', async () => {
    await tns.addRecord(node, user1.address);
    expect(await tns.connect(user1).getAddr(node)).is.equal(user1.address);
    await tns.deleteRecord(node);
    expect(await tns.connect(user1).getAddr(node)).is.equal(
      '0x0000000000000000000000000000000000000000'
    );
  });

  it('Can set key:value pairs', async () => {
    await tns.setText(node, 'name', 'Alexandre');
    expect(await tns.getText(node, 'name')).is.equal('Alexandre');
  });

  it('Can provide string and return Keccak', async () => {
    expect(await tns.getKeccak('0033612345678')).is.equal(node);
  });
});
