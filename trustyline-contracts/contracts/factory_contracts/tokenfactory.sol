//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "./privacy.sol";

contract TokenFactory is ERC777, Privacy {
    bytes32 public constant TOKEN_FACTORY_NAME = keccak256("TOKEN_FACTORY");
    uint256 public constant TOKEN_FACTORY_VERSION = 1000;

    constructor(
        address creator,
        string memory name,
        string memory symbol,
        address[] memory defaultOperators
    ) ERC777(name, symbol, defaultOperators) {
        owner = creator;
        userAllow[creator] = true;
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

    function getFactoryname() public pure returns (bytes32) {
        return TOKEN_FACTORY_NAME;
    }

    function getFactoryVersion() public pure returns (uint256) {
        return TOKEN_FACTORY_VERSION;
    }
}
