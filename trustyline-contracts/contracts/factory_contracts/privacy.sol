//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract Privacy {
    bool public isPublic;

    address[] public usersAllowList;
    mapping(address => uint256) internal indexOf; //1 based indexing. 0 means non-existent
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Sorry, action not allow by user");
        _;
    }

    function setPublic(bool openToPublic) public onlyOwner {
        isPublic = openToPublic;
    }

    function addUser(address userAddr) public onlyOwner {
        if (indexOf[userAddr] == 0) {
            usersAllowList.push(userAddr);
            indexOf[userAddr] = usersAllowList.length;
        }
    }

    function getUserList() public view returns (address[] memory) {
        return usersAllowList;
    }

    function removeUser(address userAddr) public onlyOwner {
        uint256 index = indexOf[userAddr];
        if (userAddr != owner && index > 0 && index <= usersAllowList.length) {
            // Can t remove account owner from userAllowList
            if (index != usersAllowList.length) {
                address lastUserAccount = usersAllowList[
                    usersAllowList.length - 1
                ];

                // 1-based indexing
                usersAllowList[index - 1] = lastUserAccount;
            }

            // Remove last empty element
            usersAllowList.pop();

            // remove index userAccount from mapping
            indexOf[userAddr] = 0;
        }
    }

    function isUserAllowed(address userAddr) public view returns (bool) {
        bool allow = false;
        if (isPublic || indexOf[userAddr] != 0) {
            allow = true;
        }
        return allow;
    }
}
