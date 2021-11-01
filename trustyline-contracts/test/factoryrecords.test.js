const { expect } = require('chai');
const { ethers } = require('hardhat');
const { utils, BigNumber } = ethers;

let factoryRecords;
let accounts;

beforeEach(async () => {
  accounts = await ethers.getSigners();

  const FactoryRecords = await ethers.getContractFactory('FactoryRecords');
  factoryRecords = await FactoryRecords.deploy(accounts[0].address);
  await factoryRecords.deployed();

  for (let index = 0; index < 3; index++) {
    await factoryRecords.addDepl(
      accounts[index].address,
      accounts[index].address,
      utils.keccak256(utils.toUtf8Bytes(index.toString())),
      index
    );
  }
});

describe('Factory Records', () => {
  it('Can add new Depls in Factory Records', async () => {
    const deplContractList = await factoryRecords.getContractDeplList();
    expect(deplContractList).is.of.length(3);

    for (let index = 0; index < 3; index++) {
      expect(deplContractList[index]).to.eql([
        accounts[index].address,
        accounts[index].address,
        utils.keccak256(utils.toUtf8Bytes(index.toString())),
        BigNumber.from(index),
      ]);
    }
  });

  it('Can remove Depls in Factory Records', async () => {
    await factoryRecords.removeDepl(accounts[1].address);
    const deplContractList = await factoryRecords.getContractDeplList();
    expect(deplContractList).is.of.length(2);

    expect(deplContractList[0]).to.eql([
      accounts[0].address,
      accounts[0].address,
      utils.keccak256(utils.toUtf8Bytes('0')),
      BigNumber.from(0),
    ]);

    expect(deplContractList[1]).to.eql([
      accounts[2].address,
      accounts[2].address,
      utils.keccak256(utils.toUtf8Bytes('2')),
      BigNumber.from(2),
    ]);
  });

  it('Can get contract deployement count by contract name', async () => {
    expect(
      await factoryRecords.getCountByContractName(
        utils.keccak256(utils.toUtf8Bytes('0'))
      )
    ).is.equal(1);
  });

  it('Can get contract deployement count by User Address', async () => {
    expect(
      await factoryRecords.getCountByUserAddr(accounts[0].address)
    ).is.equal(1);
  });
});
