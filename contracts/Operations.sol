pragma solidity ^0.8.9;

library Operations {
    /// @notice zkSync circuit operation type
    enum OpType {
        Noop,
        Deposit,
        TransferToNew,
        PartialExit,
        _CloseAccount, // used for correct op id offset
        Transfer,
        FullExit,
        ChangePubKey,
        ForcedExit,
        MintNFT,
        WithdrawNFT,
        Swap
    }

    function writeDepositPubdataForPriorityQueue(Deposit memory op) internal pure returns (bytes memory buf) {
        buf = abi.encodePacked(
            uint8(OpType.Deposit),
            bytes4(0), // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenId, // tokenId
            op.amount, // amount
            op.owner // owner
        );
    }

    // Deposit pubdata
    struct Deposit {
        // uint8 opType
        uint32 accountId;
        uint32 tokenId;
        uint256 amount;
        address owner;
    }
}