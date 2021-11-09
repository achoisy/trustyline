//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ISubscriptionHandler {
    struct Subscription {
        uint8 level;
        uint256 endDate;
    }

    function setSubscription(
        address userAddr,
        uint8 userLevel,
        uint256 userPeriod
    ) external;

    function getSubscription(address userAddr)
        external
        view
        returns (Subscription memory);

    function checkSubscription(address userAddr, uint8 contractLevel)
        external
        view
        returns (bool);
}
