//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./factory_contracts/tokenfactory.sol";

contract MainFactory is AccessControlEnumerable {
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    FactoryRecords public factoryRecords;

    event NewFactoryDeploy(address indexed factoryRecordAddr);
    event NewTokenDeploy(address indexed tokenAddr, address indexed owner);

    constructor() {
        _setupRole(FACTORY_ROLE, msg.sender);
        deployFactoryRecords();
    }

    function deployFactoryRecords() public onlyRole(FACTORY_ROLE) {
        factoryRecords = new FactoryRecords(msg.sender);
        emit NewFactoryDeploy(address(factoryRecords));
    }

    function deployToken(string memory name, string memory symbol) public {
        TokenFactory tokenFactory = new TokenFactory(
            msg.sender,
            name,
            symbol,
            new address[](0)
        );

        bytes32 _factoryName = tokenFactory.getFactoryname();
        uint256 _version = tokenFactory.getFactoryVersion();

        factoryRecords.newDepls(
            address(tokenFactory),
            msg.sender,
            _factoryName,
            _version
        );

        emit NewTokenDeploy(address(tokenFactory), msg.sender);
    }
}

contract FactoryRecords is AccessControlEnumerable {
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
