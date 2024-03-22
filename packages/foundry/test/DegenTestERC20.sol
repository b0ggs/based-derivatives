// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "../contracts/1099/ERC20.sol";

// ERC721Template Contract
contract DegenTestERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol, decimals) {
        _mint(msg.sender, 100000 * 1e18);
    }
}
