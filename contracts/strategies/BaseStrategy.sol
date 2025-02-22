// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

// External Libraries
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
// Interfaces
import {IAllo} from "../core/IAllo.sol";
import {IStrategy} from "./IStrategy.sol";
// Internal Libraries
import {Transfer} from "../core/libraries/Transfer.sol";

abstract contract BaseStrategy is IStrategy, Transfer {
    /// ==========================
    /// === Storage Variables ====
    /// ==========================

    IAllo internal immutable allo;
    uint256 internal poolId;
    bytes32 internal strategyId;
    uint256 internal poolAmount;
    bool internal poolActive;

    /// ====================================
    /// ========== Constructor =============
    /// ====================================

    /// @param _allo Address of the Allo contract
    constructor(address _allo, string memory _name) {
        allo = IAllo(_allo);
        strategyId = keccak256(abi.encode(_name));
    }

    /// ====================================
    /// =========== Modifiers ==============
    /// ====================================

    /// @notice Modifier to check if the caller is the Allo contract
    modifier onlyAllo() {
        if (msg.sender != address(allo)) {
            revert BaseStrategy_UNAUTHORIZED();
        }
        _;
    }

    /// @notice Modifier to check if the caller is a pool manager
    modifier onlyPoolManager(address _sender) {
        if (!allo.isPoolManager(poolId, _sender)) {
            revert BaseStrategy_UNAUTHORIZED();
        }
        _;
    }

    /// @notice Modifier to check if the pool is active
    modifier onlyActivePool() {
        if (!poolActive) {
            revert BaseStrategy_POOL_INACTIVE();
        }
        _;
    }

    modifier onlyInitialized() {
        if (poolId == 0) {
            revert BaseStrategy_NOT_INITIALIZED();
        }
        _;
    }

    /// ================================
    /// =========== Views ==============
    /// ================================

    function getAllo() external view override returns (IAllo) {
        return allo;
    }

    function getPoolId() external view override returns (uint256) {
        return poolId;
    }

    function getStrategyId() external view override returns (bytes32) {
        return strategyId;
    }

    function getPoolAmount() external view virtual override returns (uint256) {
        return poolAmount;
    }

    function isPoolActive() external override returns (bool) {
        return _isPoolActive();
    }

    /// ====================================
    /// =========== Functions ==============
    /// ====================================

    /// @notice Initializes the allocation strategy
    /// @param _poolId Id of the pool
    /// @dev This function is called by Allo.sol
    function __BaseStrategy_init(uint256 _poolId) internal virtual onlyAllo {
        if (poolId != 0) {
            revert BaseStrategy_ALREADY_INITIALIZED();
        }
        poolId = _poolId;
    }

    function increasePoolAmount(uint256 _amount) external override onlyAllo {
        poolAmount += _amount;
    }

    function registerRecipient(bytes memory _data, address _sender)
        external
        payable
        onlyAllo
        onlyInitialized
        returns (address)
    {
        return _registerRecipient(_data, _sender);
    }

    function allocate(bytes memory _data, address _sender) external payable onlyAllo onlyInitialized {
        return _allocate(_data, _sender);
    }

    function distribute(address[] memory _recipientIds, bytes memory _data, address _sender)
        external
        onlyAllo
        onlyInitialized
    {
        return _distribute(_recipientIds, _data, _sender);
    }

    /// ====================================
    /// ============ Internal ==============
    /// ====================================

    // set the pool to active or inactive
    function _setPoolActive(bool _active) internal {
        poolActive = _active;
        emit PoolActive(_active);
    }

    // this will hold logic to determine if a pool is active or not
    function _isPoolActive() internal virtual returns (bool) {
        return poolActive;
    }

    // this is called via allo.sol to register recipients
    // it can change their status all the way to Accepted, or to Pending if there are more steps
    // if there are more steps, additional functions should be added to allow the owner to check
    // this could also check attestations directly and then Accept
    function _registerRecipient(bytes memory _data, address _sender) internal virtual returns (address);

    // only called via allo.sol by users to allocate to a recipient
    // this will update some data in this contract to store votes, etc.
    function _allocate(bytes memory _data, address _sender) internal virtual;

    // this will distribute tokens to recipients
    // most strategies will track a TOTAL amount per recipient, and a PAID amount, and pay the difference
    // this contract will need to track the amount paid already, so that it doesn't double pay
    function _distribute(address[] memory _recipientIds, bytes memory _data, address _sender) internal virtual;
}
