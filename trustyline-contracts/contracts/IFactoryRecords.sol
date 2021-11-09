//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IFactoryRecords {
    struct ContractDepl {
        address deplAddr;
        address ownerAddr;
        bytes32 deplName;
        uint256 version;
    }

    function addDepl(
        address _deplAddr,
        address _ownerAddr,
        bytes32 _deplName,
        uint256 _version
    ) external returns (bool res);

    function removeDepl(address _deplAddr) external returns (bool res);

    function getCountByContractName(bytes32 _deplName)
        external
        view
        returns (uint256);

    function getCountByUserAddr(address _ownerAddr)
        external
        view
        returns (uint256);

    function getContractDeplList()
        external
        view
        returns (ContractDepl[] memory);
}
