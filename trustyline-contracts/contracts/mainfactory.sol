//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./factory_contracts/tokenfactory.sol";
import "./mock_contracts/IAccountRules.sol";
import "./ISubscription.sol";
import "./IFactoryRecords.sol";

contract MainFactory is AccessControlEnumerable {
    event Log(string message);
    event LogBytes(bytes data);

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    IAccountRules public accountRules;
    IFactoryRecords public factoryRecords;
    ISubscriptionHandler public subscriptionService;

    uint8 public TokenFactoryLevel = 0;

    modifier requireAccountRules() {
        require(address(accountRules) != address(0), "AccountRules not set !");
        _;
    }

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

    constructor() {
        _setupRole(FACTORY_ROLE, msg.sender);
    }

    function setAccountRules(address _accountRules)
        public
        onlyRole(FACTORY_ROLE)
    {
        accountRules = IAccountRules(_accountRules);
    }

    function setFactoryRecords(address _factoryRecords)
        public
        onlyRole(FACTORY_ROLE)
    {
        factoryRecords = IFactoryRecords(_factoryRecords);
    }

    function setSubscriptionService(address _subscriptionService)
        public
        onlyRole(FACTORY_ROLE)
    {
        subscriptionService = ISubscriptionHandler(_subscriptionService);
    }

    function checkSubscription(uint8 level)
        private
        view
        requireFatcoryRecords
        returns (bool)
    {
        if (level > 0) {
            return subscriptionService.checkSubscription(msg.sender, level);
        }
        return true;
    }

    function deployToken(string memory name, string memory symbol) public {
        TokenFactory tokenFactory = new TokenFactory(
            msg.sender,
            name,
            symbol,
            new address[](0)
        );

        bytes32 _factoryName = tokenFactory.getContractName();
        uint256 _version = tokenFactory.getContractVersion();

        AddContractRecord(
            address(tokenFactory),
            msg.sender,
            _factoryName,
            _version
        );

        AddContractPerm(address(tokenFactory));
    }

    function AddContractPerm(address deployContract)
        private
        requireAccountRules
    {
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

    function AddContractRecord(
        address deplContract,
        address owner,
        bytes32 _factoryName,
        uint256 _version
    ) private requireSubscription(TokenFactoryLevel) {
        try
            factoryRecords.addDepl(deplContract, owner, _factoryName, _version)
        returns (bool res) {
            if (res) {
                emit Log("Contract Added successfully to factoryRecords !");
            }
        } catch Error(string memory reason) {
            emit Log(reason);
        } catch (bytes memory lowLevelData) {
            emit LogBytes(lowLevelData);
        }
    }
}
