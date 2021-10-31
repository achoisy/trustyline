//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "./privacy.sol";

contract TokenFactory is ERC777, Privacy {
    bytes32 public constant CONTRACT_NAME = keccak256("TOKEN_FACTORY");
    uint256 public constant CONTRACT_VERSION = 1000;

    constructor(
        address creator,
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) ERC777(name, symbol, defaultOperators) {
        owner = creator;
        usersAllowList.push(owner);
        indexOf[owner] = usersAllowList.length;
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount, "", "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, amount);
        require(isUserAllowed(msg.sender), "Sorry, this contract is private");
    }

    function getContractName() public pure returns (bytes32) {
        return CONTRACT_NAME;
    }

    function getContractVersion() public pure returns (uint256) {
        return CONTRACT_VERSION;
    }
}
