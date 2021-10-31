//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./factory_contracts/tokenfactory.sol";
import "./mock_contracts/accountRules.sol";
import "./subscription.sol";

contract MainFactory is AccessControlEnumerable {
    event Log(string message);
    event LogBytes(bytes data);
    event NewFactoryDeploy(address indexed dplAddr, string name);
    event NewTokenDeploy(address indexed tokenAddr, address indexed owner);

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    AccountRules public accountRules;
    FactoryRecords public factoryRecords;
    SubscriptionHandler public subscriptionService;

    modifier requireFatcoryRecords() {
        require(
            address(factoryRecords) != address(0),
            "Factory records not set !"
        );
        _;
    }

    modifier requireSubscription() {
        require(
            address(subscriptionService) != address(0),
            "Subscription service not set !"
        );
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
    {
        TokenFactory tokenFactory = new TokenFactory(
            msg.sender,
            name,
            symbol,
            new address[](0)
        );

        bytes32 _factoryName = tokenFactory.getContractName();
        uint256 _version = tokenFactory.getContractVersion();

        factoryRecords.newDepls(
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

    function checkSubscription(uint8) private {}
}

contract FactoryRecords is AccessControlEnumerable {
    // TODO: remove deleted DPls from lists
    struct ContractDepl {
        address deplAddr;
        address ownerAddr;
        uint256 version;
        bool deleted;
    }

    struct UserDepl {
        address deplAddr;
        bytes32 deplName;
        uint256 version;
    }

    bytes32 public constant FACTORY_RECORD_ROLE =
        keccak256("FACTORY_RECORD_ROLE");

    mapping(address => UserDepl[]) public userDepls;
    mapping(bytes32 => ContractDepl[]) public contractDepls;

    constructor(address creator) {
        _setupRole(FACTORY_RECORD_ROLE, msg.sender);
        _setupRole(FACTORY_RECORD_ROLE, creator);
        // _setupRole(DEFAULT_ADMIN_ROLE, creator);
    }

    function newDepls(
        address _deplAddr,
        address _ownerAddr,
        bytes32 _deplName,
        uint256 _version
    ) public onlyRole(FACTORY_RECORD_ROLE) {
        userDepls[_ownerAddr].push(
            UserDepl({
                deplAddr: _deplAddr,
                deplName: _deplName,
                version: _version
            })
        );
        contractDepls[_deplName].push(
            ContractDepl({
                deplAddr: _deplAddr,
                ownerAddr: _ownerAddr,
                version: _version,
                deleted: false
            })
        );
    }

    function getContractDeplList(bytes32 factoryName)
        public
        view
        returns (ContractDepl[] memory)
    {
        return contractDepls[factoryName];
    }

    function getUserDeplList(address userAddr)
        public
        view
        returns (UserDepl[] memory)
    {
        return userDepls[userAddr];
    }
}
