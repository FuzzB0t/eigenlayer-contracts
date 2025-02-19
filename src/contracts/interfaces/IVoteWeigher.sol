// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

import "../interfaces/IStrategyManager.sol";
import "../interfaces/IServiceManager.sol";
import "../interfaces/ISlasher.sol";
import "../interfaces/IDelegationManager.sol";

/**
 * @title Interface for a `VoteWeigher`-type contract.
 * @author Layr Labs, Inc.
 * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service
 * @notice Note that `NUMBER_OF_QUORUMS` is expected to remain constant, as suggested by its uppercase formatting.
 */
interface IVoteWeigher {
    /// @notice emitted when a new quorum is created
    event QuorumCreated(uint8 indexed quorumNumber);
    /// @notice emitted when `strategy` has been added to the array at `strategiesConsideredAndMultipliers[quorumNumber]`
    event StrategyAddedToQuorum(uint8 indexed quorumNumber, IStrategy strategy);
    /// @notice emitted when `strategy` has removed from the array at `strategiesConsideredAndMultipliers[quorumNumber]`
    event StrategyRemovedFromQuorum(uint8 indexed quorumNumber, IStrategy strategy);
    /// @notice emitted when `strategy` has its `multiplier` updated in the array at `strategiesConsideredAndMultipliers[quorumNumber]`
    event StrategyMultiplierUpdated(uint8 indexed quorumNumber, IStrategy strategy, uint256 multiplier);

    /**
     * @notice In weighing a particular strategy, the amount of underlying asset for that strategy is
     * multiplied by its multiplier, then divided by WEIGHTING_DIVISOR
     */
    struct StrategyAndWeightingMultiplier {
        IStrategy strategy;
        uint96 multiplier;
    }

    /// @notice Constant used as a divisor in calculating weights.
    function WEIGHTING_DIVISOR() external pure returns (uint256);

    /// @notice Returns the EigenLayer strategy manager contract.
    function strategyManager() external view returns (IStrategyManager);

    /// @notice Returns the EigenLayer slasher contract.
    function slasher() external view returns (ISlasher);

    /// @notice Returns the EigenLayer delegation manager contract.
    function delegation() external view returns (IDelegationManager);

    /// @notice Returns the AVS service manager contract.
    function serviceManager() external view returns (IServiceManager);

    /**
     * @notice This function computes the total weight of the @param operator in the quorum @param quorumNumber.
     * @dev reverts in the case that `quorumNumber` is greater than or equal to `quorumCount`
     */
    function weightOfOperatorForQuorum(uint8 quorumNumber, address operator) external view returns (uint96);

    /// @notice Number of quorums that are being used by the middleware.
    function quorumCount() external view returns (uint16);

    /// @notice Returns the strategy and weight multiplier for the `index`'th strategy in the quorum `quorumNumber`
    function strategyAndWeightingMultiplierForQuorumByIndex(
        uint8 quorumNumber,
        uint256 index
    ) external view returns (StrategyAndWeightingMultiplier memory);

    /// @notice Create a new quorum and add the strategies and their associated weights to the quorum.
    function createQuorum(StrategyAndWeightingMultiplier[] memory _strategiesConsideredAndMultipliers) external;

    /// @notice Adds new strategies and the associated multipliers to the @param quorumNumber.
    function addStrategiesConsideredAndMultipliers(
        uint8 quorumNumber,
        StrategyAndWeightingMultiplier[] memory _newStrategiesConsideredAndMultipliers
    ) external;

    /**
     * @notice This function is used for removing strategies and their associated weights from the
     * mapping strategiesConsideredAndMultipliers for a specific @param quorumNumber.
     * @dev higher indices should be *first* in the list of @param indicesToRemove, since otherwise
     * the removal of lower index entries will cause a shift in the indices of the other strategiesToRemove
     */
    function removeStrategiesConsideredAndMultipliers(uint8 quorumNumber, uint256[] calldata indicesToRemove) external;

    /**
     * @notice This function is used for modifying the weights of strategies that are already in the
     * mapping strategiesConsideredAndMultipliers for a specific
     * @param quorumNumber is the quorum number to change the strategy for
     * @param strategyIndices are the indices of the strategies to change
     * @param newMultipliers are the new multipliers for the strategies
     */
    function modifyStrategyWeights(
        uint8 quorumNumber,
        uint256[] calldata strategyIndices,
        uint96[] calldata newMultipliers
    ) external;

    /// @notice Returns the length of the dynamic array stored in `strategiesConsideredAndMultipliers[quorumNumber]`.
    function strategiesConsideredAndMultipliersLength(uint8 quorumNumber) external view returns (uint256);
}
