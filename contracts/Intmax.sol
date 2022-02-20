pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Storage.sol";
import {Operations} from "./Operations.sol";
import {Events} from "./Events.sol";
import {Utils} from "./Utils.sol";
import "./Config.sol";

import "hardhat/console.sol";

contract Intmax is Storage, ReentrancyGuard, Events, Config {
    constructor(bytes memory params) {
        address _governanceAddress = abi.decode(params, (address));

        governance = Governance(_governanceAddress);
    }

    /// @notice Data needed to process onchain operation from block public data.
    /// @notice Onchain operations is operations that need some processing on L1: Deposits, Withdrawals, ChangePubKey.
    /// @param ethWitness Some external data that can be needed for operation processing
    /// @param publicDataOffset Byte offset in public data for onchain operation
    struct OnchainOperationData {
        bytes ethWitness;
        uint32 publicDataOffset;
    }

    /// @notice Data needed to commit new block
    struct CommitBlockInfo {
        bytes32 newStateHash;
        bytes publicData;
        uint256 timestamp;
        OnchainOperationData[] onchainOperations;
        uint32 blockNumber;
        uint32 feeAccount;
    }

    /// @notice Deposit ETH to Layer 2 - transfer ether from user into contract, validate it, register deposit
    /// @param _intmaxAddress The receiver Layer 2 address
    function depositETH(address _intmaxAddress) external payable notFreeze {
        require(msg.value > 0, "Value must ve greater than 0");
        registerDeposit(0, msg.value, _intmaxAddress);
    }

    /// @notice Deposit ERC20 token to Layer 2 - transfer ERC20 tokens from user into contract,
    /// validate it, register deposit
    /// @param _token Token address
    /// @param _amount Token amount
    /// @param _intmaxAddress Receiver Layer 2 address
    function depositERC20(
        IERC20 _token,
        uint256 _amount,
        address _intmaxAddress
    ) external nonReentrant notFreeze {
        // Get token id by its address
        uint16 tokenId = governance.validateTokenAddress(address(_token));
        require(!governance.pausedTokens(tokenId), "This token is paused"); // token deposits are paused

        SafeERC20.safeTransferFrom(_token, msg.sender, address(this), _amount);

        registerDeposit(tokenId, _amount, _intmaxAddress);
    }

    /// @notice Register deposit request - pack pubdata, add priority request and emit OnchainDeposit event
    /// @param _tokenId Token by id
    /// @param _amount Token amount
    /// @param _intmaxAddress Receiver
    function registerDeposit(
        uint16 _tokenId,
        uint256 _amount,
        address _intmaxAddress
    ) internal {
        // Priority Queue request
        Operations.Deposit memory op = Operations.Deposit({
            accountId: 0, // unknown at this point
            owner: _intmaxAddress,
            tokenId: _tokenId,
            amount: _amount
        });
        bytes memory pubData = Operations.writeDepositPubdataForPriorityQueue(
            op
        );
        addPriorityRequest(Operations.OpType.Deposit, pubData);
        emit Deposit(_tokenId, _amount);
    }

    /// @notice Saves priority request in storage
    /// @dev Calculates expiration block for request, store this request and emit NewPriorityRequest event
    /// @param _opType Rollup operation type
    /// @param _pubData Operation pubdata
    function addPriorityRequest(
        Operations.OpType _opType,
        bytes memory _pubData
    ) internal {
        // Expiration block is: current block number + priority expiration delta
        uint64 expirationBlock = uint64(block.number + PRIORITY_EXPIRATION);

        uint64 nextPriorityRequestId = firstPriorityRequestId +
            totalOpenPriorityRequests;

        bytes20 hashedPubData = Utils.hashBytesToBytes20(_pubData);

        priorityRequests[nextPriorityRequestId] = PriorityOperation({
            hashedPubData: hashedPubData,
            expirationBlock: expirationBlock,
            opType: _opType
        });

        emit NewPriorityRequest(
            msg.sender,
            nextPriorityRequestId,
            _opType,
            _pubData,
            uint256(expirationBlock)
        );

        totalOpenPriorityRequests++;
    }

    /// @notice  Withdraws Intmax from zkSync contract to the owner
    /// @param _owner Address of the tokens owner
    /// @param _token Address of tokens, zero address is used for ETH
    /// @param _amount Amount to withdraw to request.
    ///         NOTE: We will call ERC20.transfer(.., _amount),
    ///         but if according to internal logic of ERC20 token Intmax contract
    ///         balance will be decreased by value more then _amount
    ///         we will try to subtract this value from user pending balance
    function withdrawPendingBalance(
        address payable _owner,
        address _token,
        uint256 _amount
    ) external nonReentrant {}

    /// @notice Register withdrawal - update user balance and emit OnchainWithdrawal event
    /// @param _token - token by id
    /// @param _amount - token amount
    /// @param _to - address to withdraw to
    function registerWithdrawal(
        uint16 _token,
        uint256 _amount,
        address payable _to
    ) internal {}

    function exit(
        address payable _owner,
        address _token,
        uint256 _amount
    ) external {}

    /// @dev Process one block commit using previous block StoredBlockInfo,
    /// @dev returns new block StoredBlockInfo
    /// @dev NOTE: Does not change storage (except events, so we can't mark it view)
    function commitOneBlock(
        StoredBlockInfo memory _previousBlock,
        CommitBlockInfo memory _newBlock
    ) internal view returns (StoredBlockInfo memory storedNewBlock) {}

    /// @notice Commit block
    /// @notice 1. Checks onchain operations, timestamp.
    /// @notice 2. Store block commitments
    function commitBlocks() external nonReentrant {}

    /// @notice Blocks commitment verification.
    /// @notice Only verifies block commitments without any other processing
    function proveBlocks() external nonReentrant {}

    /// @dev Executes one block
    /// @dev 1. Processes all pending operations (Send Exits, Complete priority requests)
    /// @dev 2. Finalizes block on Ethereum
    /// @dev _executedBlockIdx is index in the array of the blocks that we want to execute together
    function executeOneBlock() internal {}

    /// @notice Execute blocks, completing priority operations and processing withdrawals.
    /// @notice 1. Processes all pending operations (Send Exits, Complete priority requests)
    /// @notice 2. Finalizes block on Ethereum
    function executeBlocks() external nonReentrant {}
}
