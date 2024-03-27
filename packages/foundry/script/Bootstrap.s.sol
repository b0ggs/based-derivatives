// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import { SVGBuilder } from "../contracts/BasedDerivitives/SVGBuilder.sol";
import { BasedDerivatives } from "../contracts/BasedDerivitives/BasedDerivatives.sol";

// Current block = 7814817
// forge script script/Bootstrap.s.sol:Bootstrap --rpc-url $RPC_URL --broadcast --verify -vvvv 2>&1 | tee bootstrap.out
// forge script script/Bootstrap.s.sol:Bootstrap --broadcast --verify -vvvv 2>&1 | tee bootstrap.out
contract Bootstrap is Script {
    BasedDerivatives based = BasedDerivatives(0x744f1532597e943D0604e56cee2A9D68d543B2e3);

    using SVGBuilder for SVGBuilder.Accessory;
    using SVGBuilder for SVGBuilder.ogImageData;
    using SVGBuilder for SVGBuilder.TokenData;
    using SVGBuilder for SVGBuilder.AccessoryCallData;
    using SVGBuilder for SVGBuilder.AccessoryMintingParams;
    using SVGBuilder for SVGBuilder.Payout;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 _mintingFee = 0;
        uint256 _gateAmount = 0;
        uint16 _ercGateType = 20;
        uint16 _royalty = 1337; // now 0-10000
        address _feeAddress = address(0x036CbD53842c5426634e7929541eC2318f3dCF7e);
        address _gateAddress = address(0x0);
        SVGBuilder.AccessoryCallData memory data;
        SVGBuilder.AccessoryMintingParams memory mintingParams;

        vm.startBroadcast(deployerPrivateKey);

        // Create calldata struct
        data = SVGBuilder.AccessoryCallData({
            accessoryId: 1,         // tokenId in original contract
            totalSupply: 1000,      // total amount of this accessory that can be minted
            amountMinted: 0,        // number of accessories minted
            amountPerTokenId: 1,    // amount of this accessory that a based derivative can have in it
            traitType: "Top Hat",
            value: "Black"
        });

        mintingParams = SVGBuilder.AccessoryMintingParams({
            accessoryNFTCollection: address(0xf45cD2B137Eb3f88670CeB9efb8D5F8Ecaf72C4E),
            tokenId: 1,                 // same as accessoryId
            mintingFee: _mintingFee,    // minting fee in ERC20 currency
            gateAmount: _gateAmount,    // amount wallet must have in gateAddress balance
            feeAddress: _feeAddress,    // ERC20 for minting
            gateAddress: _gateAddress,  // contact address for gate token
            ercGateType: _ercGateType,  // 20, 721, or 1155 of gate token
            royalty: _royalty           // 0-10000 (0-100%)
        });


        _addAccessory("https://i.imgur.com/ln8ND8J.png", data, mintingParams);

        vm.stopBroadcast();
    }

    function _addAccessory(
        string memory imageURL,
        SVGBuilder.AccessoryCallData memory accessoryCallDataInput,
        SVGBuilder.AccessoryMintingParams memory mintingParamsInput
    ) internal {
        based.addAccessory(imageURL, accessoryCallDataInput, mintingParamsInput);
    }
}
