// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721A} from "../contracts/1099/ERC721A.sol";

// ERC721Template Contract
contract AccessoriesTestERC721A is ERC721A {
    error NonExistentToken();

    constructor(string memory name, string memory symbol) ERC721A(name, symbol) {}

    function mint() external {
        _mint(msg.sender, 1);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();

        return "https://i.imgur.com/ln8ND8J.png";
    }
}
