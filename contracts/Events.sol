pragma solidity ^0.8.9;

import "./Operations.sol";


/// @title Intmax events
interface Events {
    /// @notice New priority request event. Emitted when a request is placed into mapping
    event NewPriorityRequest(
        address sender,
        uint64 serialId,
        Operations.OpType opType,
        bytes pubData,
        uint256 expirationBlock
    );

    /// @notice Event emitted when user funds are deposited to the Intmax contract
    event Deposit(uint16 indexed tokenId, uint256 amount);
}