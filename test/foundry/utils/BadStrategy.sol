// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAllo} from "../../../contracts/core/IAllo.sol";
import {IStrategy} from "../../../contracts/strategies/IStrategy.sol";

contract BadStrategy is IStrategy {
    // ======================
    // ======= Storage ======
    // ======================

    // Initialize storage variables
    IAllo private allo;
    uint256 private poolId;
    bytes32 private strategyId;
    bool private poolActive;
    uint256 private poolAmount;
    mapping(address => RecipientStatus) private recipientStatus;

    // ======================
    // ======= Views ========
    // ======================

    function getAllo() external view override returns (IAllo) {
        return allo;
    }

    function getPoolId() external view override returns (uint256) {
        return poolId;
    }

    function getStrategyId() external view override returns (bytes32) {
        return strategyId;
    }

    function isValidAllocator(address) external pure override returns (bool) {
        return true; // For mock, always return true
    }

    function isPoolActive() external view override returns (bool) {
        return poolActive;
    }

    function getPoolAmount() external view override returns (uint256) {
        return poolAmount;
    }

    function getRecipientStatus(address _recipientId) external view override returns (RecipientStatus) {
        return recipientStatus[_recipientId];
    }

    function getPayouts(address[] memory _recipientIds, bytes memory, address)
        external
        pure
        override
        returns (PayoutSummary[] memory)
    {
        PayoutSummary[] memory payouts = new PayoutSummary[](_recipientIds.length);
        for (uint256 i = 0; i < _recipientIds.length; i++) {
            payouts[i] = PayoutSummary({recipientAddress: _recipientIds[i], amount: 0});
        }
        return payouts;
    }

    function increasePoolAmount(uint256 _amount) external {}

    // ======================
    // ===== Functions ======
    // ======================
    function initialize(uint256, bytes memory) external override {
        // For mock, do nothing in the initialize function
    }

    function registerRecipient(bytes memory, address) external payable override returns (address) {
        // For mock, do nothing in the registerRecipient function and return address(0)
        return address(0);
    }

    function allocate(bytes memory, address) external payable override {
        // For mock, do nothing in the allocate function
    }

    function distribute(address[] memory, bytes memory, address) external override {
        // For mock, do nothing in the distribute function
    }

    function setAllo(address _allo_) external {
        allo = IAllo(_allo_);
    }

    function setPoolId(uint256 _poolId_) external {
        poolId = _poolId_;
    }
}
