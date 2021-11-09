module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, execute } = deployments;
  const { deployer } = await getNamedAccounts();

  const mainFactory = await deploy('MainFactory', {
    from: deployer,
    // args: [deployer],
    log: true,
  });

  const accountRules = await deployments.get('AccountRules');
  await execute(
    'MainFactory',
    { from: deployer },
    'setAccountRules',
    accountRules.address
  );

  const subscription = await deployments.get('SubscriptionHandler');
  await execute(
    'MainFactory',
    { from: deployer },
    'setSubscriptionService',
    subscription.address
  );

  const factoryRecords = await deploy('FactoryRecords', {
    from: deployer,
    args: [deployer],
    log: true,
  });

  await execute(
    'MainFactory',
    { from: deployer },
    'setFactoryRecords',
    factoryRecords.address
  );
};

module.exports.tags = ['MainFactory'];
