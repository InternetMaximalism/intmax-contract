pragma solidity ^0.8.9;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("TestERC20", "TE") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
