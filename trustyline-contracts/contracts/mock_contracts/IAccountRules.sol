//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IAccountRules {
    function addAccount(address account) external returns (bool);

    function removeAccount(address account) external returns (bool);

    function accountPermitted(address _account) external view returns (bool);
}
