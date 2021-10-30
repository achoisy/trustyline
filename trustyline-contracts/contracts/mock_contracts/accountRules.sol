//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract AccountRules {
    address public admin;

    address[] public allowlist;
    mapping(address => uint256) private indexOf; //1 based indexing. 0 means non-existent

    event AddedAccount(address indexed account, uint256 indexOf);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Sender not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
        add(msg.sender);
    }

    function addAccount(address account) external returns (bool) {
        bool added = add(account);
        return added;
    }

    function removeAccount(address account) external returns (bool) {
        bool removed = remove(account);
        return removed;
    }

    function add(address _account) private returns (bool) {
        if (indexOf[_account] == 0) {
            allowlist.push(_account);
            indexOf[_account] = allowlist.length;
            emit AddedAccount(_account, indexOf[_account]);
            return true;
        }
        return false;
    }

    function remove(address _account) private returns (bool) {
        uint256 index = indexOf[_account];
        if (index > 0 && index <= allowlist.length) {
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != allowlist.length) {
                address lastAccount = allowlist[allowlist.length - 1];

                //1-based indexing
                allowlist[index - 1] = lastAccount;
                indexOf[lastAccount] = index;
            }

            // Remove last empty element
            allowlist.pop();

            // remove index from mapping
            indexOf[_account] = 0;

            return true;
        }
        return false;
    }

    function accountPermitted(address _account) public view returns (bool) {
        return exists(_account);
    }

    function exists(address _account) internal view returns (bool) {
        return indexOf[_account] != 0;
    }
}
