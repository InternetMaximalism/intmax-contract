pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Config.sol";

contract Governance is AccessControl, Config {
    /// @notice Token added to Intmax
    event NewToken(address indexed token, uint16 indexed tokenId);


    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");


    /// @notice Paused tokens list, deposits are impossible to create for paused tokens
    mapping(uint16 => bool) public pausedTokens;

    /// @notice List of registered tokens by address
    mapping(address => uint16) public tokenIds;

    /// @notice List of registered tokens by tokenId
    mapping(uint16 => address) public tokenAddresses;

    /// @notice Total number of ERC20 tokens registered in the network (excluding ETH, which is hardcoded as tokenId = 0)
    uint16 public totalTokens;

    constructor() {
        _setupRole(GOVERNANCE_ROLE, msg.sender);
    }

    /// @notice Validate token address
    /// @param _tokenAddr Token address
    /// @return tokens id
    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {
        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "_tokenAddr is not registered"); // 0 is not a valid token
        return tokenId;
    }

    // @notice Add token to the list of networks tokens
    /// @param _token Token address
    function addToken(address _token) external onlyRole(GOVERNANCE_ROLE) {
        require(tokenIds[_token] == 0, "this token has already registered"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "totalTokens has already reach the max amount"); // no free identifiers for tokens

        totalTokens++;
        uint16 newTokenId = totalTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }


}