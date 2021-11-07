//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract SubscriptionHandler is AccessControlEnumerable {
    struct Subscription {
        uint8 level;
        uint256 endDate;
    }

    bytes32 public constant SUBS_ROLE = keccak256("SUBS_ROLE");

    mapping(address => Subscription) subscriptions;

    event SetSubscription(
        address indexed userAddr,
        uint8 userLevel,
        uint256 endDate
    );

    constructor(address creator) {
        _setupRole(SUBS_ROLE, msg.sender);
        if (msg.sender != creator) {
            _setupRole(SUBS_ROLE, creator);
        }
    }

    // userPeriod is in seconds
    function setSubscription(
        address userAddr,
        uint8 userLevel,
        uint256 userPeriod
    ) public onlyRole(SUBS_ROLE) {
        uint256 endDate = block.timestamp + userPeriod;
        subscriptions[userAddr].level = userLevel;
        subscriptions[userAddr].endDate = endDate;
        emit SetSubscription(userAddr, userLevel, endDate);
    }

    function getSubscription(address userAddr)
        public
        view
        returns (Subscription memory)
    {
        return subscriptions[userAddr];
    }

    function checkSubscription(address userAddr, uint8 contractLevel)
        public
        view
        returns (bool)
    {
        bool valid = false;
        if (
            subscriptions[userAddr].level >= contractLevel &&
            subscriptions[userAddr].endDate > block.timestamp
        ) {
            valid = true;
        }
        return valid;
    }
}
