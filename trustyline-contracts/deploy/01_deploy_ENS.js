module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('ENSCustomRegistry', {
    from: deployer,
    log: true,
  });

  await deploy('OwnedResolver', {
    from: deployer,
    log: true,
  });
};

module.exports.tags = ['ENS'];
