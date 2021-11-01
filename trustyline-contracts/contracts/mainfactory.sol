//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./factory_contracts/tokenfactory.sol";
import "./mock_contracts/accountRules.sol";
import "./subscription.sol";
import "./factoryrecords.sol";

contract MainFactory is AccessControlEnumerable {
    event Log(string message);
    event LogBytes(bytes data);
    event NewFactoryDeploy(address indexed dplAddr, string name);
    event NewTokenDeploy(address indexed tokenAddr, address indexed owner);

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    AccountRules public accountRules;
    FactoryRecords public factoryRecords;
    SubscriptionHandler public subscriptionService;

    uint8 public TokenFactoryLevel = 0;

    modifier requireFatcoryRecords() {
        require(
            address(factoryRecords) != address(0),
            "Factory records not set !"
        );
        _;
    }

    modifier requireSubscription(uint8 level) {
        require(
            address(subscriptionService) != address(0),
            "Subscription service not set !"
        );
        require(checkSubscription(level), "Subscription not valid, sorry!");
        _;
    }

    constructor(address _accountRules) {
        _setupRole(FACTORY_ROLE, msg.sender);
        accountRules = AccountRules(_accountRules);
    }

    function deployFactoryRecords() public onlyRole(FACTORY_ROLE) {
        factoryRecords = new FactoryRecords(msg.sender);
        AddContractPerm(address(factoryRecords));
        emit NewFactoryDeploy(
            address(factoryRecords),
            "FactoryRecords deployement"
        );
    }

    function deploySubscriptionService() public onlyRole(FACTORY_ROLE) {
        subscriptionService = new SubscriptionHandler(msg.sender);
        emit NewFactoryDeploy(
            address(subscriptionService),
            "SubscriptionHandler deployement"
        );
    }

    function deployToken(string memory name, string memory symbol)
        public
        requireFatcoryRecords
        requireSubscription(TokenFactoryLevel)
    {
        TokenFactory tokenFactory = new TokenFactory(
            msg.sender,
            name,
            symbol,
            new address[](0)
        );

        bytes32 _factoryName = tokenFactory.getContractName();
        uint256 _version = tokenFactory.getContractVersion();

        factoryRecords.addDepl(
            address(tokenFactory),
            msg.sender,
            _factoryName,
            _version
        );

        AddContractPerm(address(tokenFactory));
        emit NewTokenDeploy(address(tokenFactory), msg.sender);
    }

    function AddContractPerm(address deployContract) private {
        try accountRules.addAccount(deployContract) returns (bool res) {
            if (res) {
                emit Log("AccountRules Added successfully !");
            }
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch (bytes memory lowLevelData) {
            emit LogBytes(lowLevelData);
        }
    }

    function checkSubscription(uint8 level) private view returns (bool) {
        if (level > 0) {
            return subscriptionService.checkSubscription(msg.sender, level);
        }
        return true;
    }
}
