//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FactoryRecords is AccessControlEnumerable {
    using Counters for Counters.Counter;

    event DeplRecordAdded(
        address indexed dplAddr,
        address indexed ownerAddr,
        bytes32 deplName,
        uint256 version
    );
    event DeplRecordRemoved(
        address indexed dplAddr,
        address indexed ownerAddr,
        bytes32 deplName,
        uint256 version
    );

    struct ContractDepl {
        address deplAddr;
        address ownerAddr;
        bytes32 deplName;
        uint256 version;
    }

    bytes32 public constant FACTORY_RECORD_ROLE =
        keccak256("FACTORY_RECORD_ROLE");

    ContractDepl[] public contractDepls;

    mapping(address => uint256) internal indexOfContractDepl;
    mapping(bytes32 => Counters.Counter) public deplCounter;
    mapping(address => Counters.Counter) public userDplCounter;

    constructor(address creator) {
        _setupRole(FACTORY_RECORD_ROLE, msg.sender);
        if (msg.sender != creator) {
            _setupRole(FACTORY_RECORD_ROLE, creator);
        }
    }

    function addDepl(
        address _deplAddr,
        address _ownerAddr,
        bytes32 _deplName,
        uint256 _version
    ) public onlyRole(FACTORY_RECORD_ROLE) {
        if (indexOfContractDepl[_deplAddr] == 0) {
            contractDepls.push(
                ContractDepl({
                    deplAddr: _deplAddr,
                    ownerAddr: _ownerAddr,
                    deplName: _deplName,
                    version: _version
                })
            );
            indexOfContractDepl[_deplAddr] = contractDepls.length;
            deplCounter[_deplName].increment();
            userDplCounter[_ownerAddr].increment();

            emit DeplRecordAdded(_deplAddr, _ownerAddr, _deplName, _version);
        } else {
            revert("Contract already registered !");
        }
    }

    function removeDepl(address _deplAddr)
        public
        onlyRole(FACTORY_RECORD_ROLE)
    {
        uint256 index = indexOfContractDepl[_deplAddr];
        if (index > 0 && index <= contractDepls.length) {
            ContractDepl memory removeDeplContract = contractDepls[index - 1];
            if (index != contractDepls.length) {
                ContractDepl memory lastContractDepl = contractDepls[
                    contractDepls.length - 1
                ];
                contractDepls[index - 1] = lastContractDepl;
            }
            contractDepls.pop();
            indexOfContractDepl[_deplAddr] = 0;

            emit DeplRecordRemoved(
                removeDeplContract.deplAddr,
                removeDeplContract.ownerAddr,
                removeDeplContract.deplName,
                removeDeplContract.version
            );
        } else {
            revert("Contract don't exist in records");
        }
    }

    function getCountByContractName(bytes32 _deplName)
        public
        view
        returns (uint256)
    {
        return deplCounter[_deplName].current();
    }

    function getCountByUserAddr(address _ownerAddr)
        public
        view
        returns (uint256)
    {
        return userDplCounter[_ownerAddr].current();
    }

    function getContractDeplList()
        public
        view
        onlyRole(FACTORY_RECORD_ROLE)
        returns (ContractDepl[] memory)
    {
        return contractDepls;
    }
}
