//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";

contract ENSCustomRegistry is ENSRegistry, AccessControl {
    bytes32 public constant ENSREGISTRY_ROLE = keccak256("ENSREGISTRY_ROLE");

    constructor() {
        _setupRole(ENSREGISTRY_ROLE, msg.sender);
    }

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external virtual override {
        require(
            hasRole(ENSREGISTRY_ROLE, msg.sender),
            "SetRecord require authorize access"
        );

        setOwner(node, owner);
        _setResolverAndTTL(node, resolver, ttl);
    }
}
