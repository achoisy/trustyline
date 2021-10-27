//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract Privacy {
    bool public isPublic;
    mapping(address => bool) userAllow;
    address[] public usersAllowList;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Sorry, action not allow");
        _;
    }

    function setPrivacy(bool openToPublic) public onlyOwner {
        isPublic = openToPublic;
    }

    function addUser(address userAddr) public onlyOwner {
        usersAllowList.push(userAddr);
        userAllow[userAddr] = true;
    }

    function removeUserByIndex(uint256 index) public onlyOwner {
        address removeUser = usersAllowList[index];
        userAllow[removeUser] = false;
        delete usersAllowList[index];
    }

    function isUserAllowed(address userAddr) public view returns (bool) {
        bool allow = false;
        if (isPublic || userAllow[userAddr]) {
            allow = true;
        }
        return allow;
    }
}
