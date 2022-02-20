pragma solidity ^0.8.9;

library Utils {
    function hashBytesToBytes20(bytes memory _bytes)
        internal
        pure
        returns (bytes20)
    {
        return bytes20(uint160(uint256(keccak256(_bytes))));
    }
}
