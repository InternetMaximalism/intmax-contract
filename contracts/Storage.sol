pragma solidity ^0.8.9;

import {Operations} from "./Operations.sol";
import "./Governance.sol";

contract Storage {
    struct StoredBlockInfo {
        uint32 blockNumber;
        uint64 priorityOperations;
        bytes32 pendingOnchainOperationsHash;
        uint256 timestamp;
        bytes32 stateHash;
        bytes32 commitment;
    }

    /// @notice Returns the keccak hash of the ABI-encoded StoredBlockInfo
    function hashStoredBlockInfo(StoredBlockInfo memory _storedBlockInfo)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_storedBlockInfo));
    }

    /// @dev Stored hashed StoredBlockInfo for some block number
    mapping(uint32 => bytes32) public storedBlockHashes;

    /// @notice Priority Operation container
    /// @member hashedPubData Hashed priority operation public data
    /// @member expirationBlock Expiration block number (ETH block) for this request (must be satisfied before)
    /// @member opType Priority operation type
    struct PriorityOperation {
        bytes20 hashedPubData;
        uint64 expirationBlock;
        Operations.OpType opType;
    }

    /// @dev Priority Requests mapping (request id - operation)
    /// @dev Contains op type, pubdata and expiration block of unsatisfied requests.
    /// @dev Numbers are in order of requests receiving
    mapping(uint64 => PriorityOperation) internal priorityRequests;

    /// @dev Total number of requests
    uint64 public totalOpenPriorityRequests;

    /// @dev First open priority request id
    uint64 public firstPriorityRequestId;

    /// @dev Flag indicates that freeze (mass exit) mode is triggered
    /// @dev Once it was raised, it can not be cleared again, and all users must exit
    bool public isFreezeMode;

    /// @notice Checks that current state not is freeze mode
    modifier notFreeze() {
        require(!isFreezeMode, "L"); // freeze mode activated
        _;
    }

    /// @dev Governance contract. Contains the governor (the owner) of whole system,
    /// validators list, possible tokens list
    Governance internal governance;
}
