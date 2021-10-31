//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

/**
 * @title TrustyLine Number Resolver
 * @dev Set & change owner of an address
 *      provide name resolution
 *      Receive name in keccak256
 */
contract TNS is AccessControlEnumerable {
    struct Record {
        address addr;
        bool isSet;
        bool isLock;
    }

    bytes32 public constant TNS_ROLE = keccak256("TNS_ROLE");

    mapping(bytes32 => Record) records;
    mapping(bytes32 => mapping(string => string)) texts;

    event NewRecord(bytes32 indexed node, address addr);
    event DeleteRecord(bytes32 indexed node);
    event NewText(bytes32 indexed node, string key, string value);
    event UpdateLock(bytes32 indexed node, bool lockState);

    modifier nodeNotLock(bytes32 node) {
        require(!records[node].isLock);
        _;
    }

    constructor(address creator) {
        _setupRole(TNS_ROLE, msg.sender);
        if (msg.sender != creator) {
            _setupRole(TNS_ROLE, creator);
        }
        records[0x0].addr = creator;
        records[0x0].isSet = true;
    }

    function addRecord(bytes32 node, address newAdrr)
        public
        onlyRole(TNS_ROLE)
    {
        records[node].isSet = true;
        records[node].isLock = false;
        records[node].addr = newAdrr;
        emit NewRecord(node, newAdrr);
    }

    function deleteRecord(bytes32 node) public onlyRole(TNS_ROLE) {
        records[node].isSet = false;
        records[node].isLock = false;
        records[node].addr = address(0x0);
        emit DeleteRecord(node);
    }

    function isRecordSet(bytes32 node) public view returns (bool) {
        return records[node].isSet;
    }

    function setLock(bytes32 node, bool lockValue) public onlyRole(TNS_ROLE) {
        records[node].isLock = lockValue;
        emit UpdateLock(node, lockValue);
    }

    function isRecordLock(bytes32 node) public view returns (bool) {
        return records[node].isLock;
    }

    function getAddr(bytes32 node)
        public
        view
        nodeNotLock(node)
        returns (address)
    {
        address addr = records[node].addr;
        // Hiding creator owner address
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) public onlyRole(TNS_ROLE) {
        texts[node][key] = value;
        emit NewText(node, key, value);
    }

    function getText(bytes32 node, string calldata key)
        external
        view
        returns (string memory)
    {
        return texts[node][key];
    }

    function getKeccak(string memory value) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(value));
    }
}
