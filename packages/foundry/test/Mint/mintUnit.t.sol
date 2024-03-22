// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AccessoriesTestERC721A.sol";
import "../DegenTestERC20.sol";
import "../../contracts/BasedDerivitives/BasedDerivatives.sol";
import "lib/forge-std/src/console.sol";
import {Test, console2, StdCheats, Vm, StdUtils} from "lib/forge-std/src/Test.sol";
import "../../contracts/1099/TenNinetyNineDAGenerator.sol";

// Check all reverts
// check totalAmount Exceeded
// Check amountPerNFT exceeded
// Check reset accessory
////TODO  refactor and test previewImageURL

//forge test -v --match-path test/Mint/mintUnit.t.sol --via-ir
contract mintUnit is Test {
    AccessoriesTestERC721A accessories;
    DegenTestERC20 degen;
    BasedDerivatives based;
    TenNinetyNineDAGenerator tnng;
    address owner;
    address[] accessoryWallets;
    address[] mintWallets;

    using SVGBuilder for SVGBuilder.Accessory;
    using SVGBuilder for SVGBuilder.ogImageData;
    using SVGBuilder for SVGBuilder.TokenData;
    using SVGBuilder for SVGBuilder.AccessoryCallData;
    using SVGBuilder for SVGBuilder.AccessoryMintingParams;
    using SVGBuilder for SVGBuilder.Payout;

    string previewImageURL = "test";

    function setUp() public {
        owner = payable(address(this));
        based = new BasedDerivatives("BasedDerivatives", "BASED", payable(owner));
        degen = new DegenTestERC20("DEGEN", "DEGEN", 18);
        _generateAccessoryWallets(5); // creates wallets {0-4} which own accessories 0-4
        _createAndMintAccessories(5); // creates ERC721 for accessories & mints 5
        uint256 accAmount = accessories.totalSupply();
        _addAllAccessories(accAmount);
        tnng = new TenNinetyNineDAGenerator("1099-DA", "NOTES");
        _generateMintWallets(5); // creates wallets {5-8}, then wallet 4 from accessories is added, which own og nft 0-4
    }

    function testOneMint() public {
        SVGBuilder.ogImageData memory _ogImage = _buildOgImageDataStruct(
            address(tnng), // collection address
            0, // tokenId
            721, //ercType
            "https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png", //imageURL
            512, // height
            768 // width
        );

        SVGBuilder.Accessory memory accessory1 = _buildAccessory(
            0, // accessoryId
            "https://ipfs.io/ipfs/QmYs8NVxVdHsxGwA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png", // imageURL
            200, // height
            300, // width
            220, // x
            0, // y
            true //isVisible
        );

        SVGBuilder.Accessory[] memory _accessories = new SVGBuilder.Accessory[](1);
        _accessories[0] = accessory1;

        uint256 mintStartDegenBalance = degen.balanceOf(mintWallets[0]);
        uint256 beneficiaryStartDegenBalance = degen.balanceOf(owner);
        uint256 royatyStartDegenBalance = degen.balanceOf(accessoryWallets[0]);
        vm.startPrank(mintWallets[0]);
        _approveExactSpending(_accessories);
        _mintBasedDerivative(_ogImage, _accessories);
        vm.stopPrank();
        uint256 basedNFTbalance = based.balanceOf(mintWallets[0]);
        assertEq(basedNFTbalance, 1);
        assertEq(degen.balanceOf(mintWallets[0]), mintStartDegenBalance - 100 * 1e18, "minters balance incorrect");
        assertEq(degen.balanceOf(owner), beneficiaryStartDegenBalance + 50 * 1e18, "beneficiary balance incorrect");
        assertEq(degen.balanceOf(accessoryWallets[0]), royatyStartDegenBalance + 50 * 1e18, "royalty balance incorrect");
    }

    function testAmountPerTokenIdExceededFail() public {
        SVGBuilder.ogImageData memory _ogImage = _buildOgImageDataStruct(
            address(tnng), // collection address
            0, // tokenId
            721, //ercType
            "https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png", //imageURL
            512, // height
            768 // width
        );

        SVGBuilder.Accessory memory accessory1 = _buildAccessory(
            0, // accessoryId
            "https://ipfs.io/ipfs/QmYs8NVxVdHsxGwA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png", // imageURL
            200, // height
            300, // width
            220, // x
            0, // y
            true //isVisible
        );

        SVGBuilder.Accessory[] memory _accessories = new SVGBuilder.Accessory[](2);
        _accessories[0] = accessory1;
        _accessories[1] = accessory1;

        vm.startPrank(mintWallets[0]);
        _approveExactSpending(_accessories);
        vm.expectRevert(0x16a5deca);
        _mintBasedDerivative(_ogImage, _accessories);
        vm.stopPrank();
    }

    function testTotalSupplyExceededFail() public {
        SVGBuilder.ogImageData memory _ogImage = _buildOgImageDataStruct(
            address(tnng), // collection address
            0, // tokenId
            721, //ercType
            "https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png", //imageURL
            512, // height
            768 // width
        );

        SVGBuilder.Accessory memory accessory1 = _buildAccessory(
            0, // accessoryId
            "https://ipfs.io/ipfs/QmYs8NVxVdHsxGwA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png", // imageURL
            200, // height
            300, // width
            220, // x
            0, // y
            true //isVisible
        );

        SVGBuilder.Accessory[] memory _accessories = new SVGBuilder.Accessory[](1);
        _accessories[0] = accessory1;

        vm.startPrank(mintWallets[0]);
        _approveExactSpending(_accessories);
        _mintBasedDerivative(_ogImage, _accessories);
        _approveExactSpending(_accessories);
        _mintBasedDerivative(_ogImage, _accessories);
        _approveExactSpending(_accessories);
        vm.expectRevert(0xfd59427a);
        _mintBasedDerivative(_ogImage, _accessories);
        vm.stopPrank();
    }

    function testWrongPaymentFail() public {
        SVGBuilder.ogImageData memory _ogImage = _buildOgImageDataStruct(
            address(tnng), // collection address
            0, // tokenId
            721, //ercType
            "https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png", //imageURL
            512, // height
            768 // width
        );

        SVGBuilder.Accessory memory accessory1 = _buildAccessory(
            0, // accessoryId
            "https://ipfs.io/ipfs/QmYs8NVxVdHsxGwA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png", // imageURL
            200, // height
            300, // width
            220, // x
            0, // y
            true //isVisible
        );

        SVGBuilder.Accessory[] memory _accessories = new SVGBuilder.Accessory[](1);
        _accessories[0] = accessory1;

        vm.startPrank(mintWallets[0]);
        _approveExactSpending(_accessories);
        // burn 901 of 1000 degen
        degen.transfer(address(0x0), 901 * 1e18);
        uint256 mintDegenBalance = degen.balanceOf(mintWallets[0]);
        console.log("balance degen");
        console.log(mintDegenBalance);
        vm.expectRevert(0x6d35ff8c);
        _mintBasedDerivative(_ogImage, _accessories);
        vm.stopPrank();
    }

    function testAccessoryURLFail() public {
        SVGBuilder.ogImageData memory _ogImage = _buildOgImageDataStruct(
            address(tnng), // collection address
            0, // tokenId
            721, //ercType
            "https://ipfs.io/ipfs/bafybeifwjhl3vdm2vgmaeoxwesafffvnnlbq4ob6ewkj3eraec7qmoukaq/15.png", //imageURL
            512, // height
            768 // width
        );

        SVGBuilder.Accessory memory accessory1 = _buildAccessory(
            0, // accessoryId
            "https://ipfs.io/ipfs/QmYs8NVxVdHsxGA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png", // imageURL
            200, // height
            300, // width
            220, // x
            0, // y
            true // isVisible
        );

        SVGBuilder.Accessory[] memory _accessories = new SVGBuilder.Accessory[](1);
        _accessories[0] = accessory1;

        vm.startPrank(mintWallets[0]);
        _approveExactSpending(_accessories);
        vm.expectRevert(0xbde7b756);
        _mintBasedDerivative(_ogImage, _accessories);
        vm.stopPrank();
    }

    function _approveExactSpending(SVGBuilder.Accessory[] memory _accessories) internal {
        (uint256 amount, address tokenAddy) = based.getTotalFeeForAccessories(_accessories);
        ERC20(tokenAddy).approve(address(based), amount);
    }

    function _approveUnlimitedDegenSpending() internal {
        degen.approve(address(based), type(uint256).max);
    }

    function _buildOgImageDataStruct(
        address _collection,
        uint256 _tokenId,
        uint16 _ercType,
        string memory _imageURL,
        uint16 _height,
        uint16 _width
    ) internal pure returns (SVGBuilder.ogImageData memory) {
        SVGBuilder.ogImageData memory ogImage = SVGBuilder.ogImageData({
            collection: _collection,
            tokenId: _tokenId,
            ercType: _ercType,
            imageURL: _imageURL,
            height: _height,
            width: _width
        });

        return ogImage;
    }

    // Function to build a single Accessory with parameters
    function _buildAccessory(
        uint256 _accessoryId,
        string memory _imageURL,
        uint16 _height,
        uint16 _width,
        uint16 _x,
        uint16 _y,
        bool _isVisible
    ) internal pure returns (SVGBuilder.Accessory memory) {
        SVGBuilder.Accessory memory accessory = SVGBuilder.Accessory({
            accessoryId: _accessoryId,
            imageURL: _imageURL,
            height: _height,
            width: _width,
            x: _x,
            y: _y,
            isVisible: _isVisible
        });

        return accessory;
    }

    function _mintBasedDerivative(SVGBuilder.ogImageData memory _ogImage, SVGBuilder.Accessory[] memory _accessories)
        internal
    {
        based.mintBasedDerivative(_ogImage, _accessories, previewImageURL);
    }

    struct AccessoryMintingParams {
        address accessoryNFTCollection; //only ERC721 // accessory Data
        uint256 tokenId; //accessory data
        uint256 mintingFee; // can't have if you have a gate
        uint256 gateAmount; // can't have if you have a fee
        address feeAddress;
        address gateAddress;
        uint16 ercGateType; //20 721 1155 do not set if no fee
        uint16 royalty; // Percentage royalty to be paid to the NFT owner 10 = 10%
    }

    function _addAllAccessories(uint256 _amount) internal {
        uint256 _totalSupply = 2;
        uint256 _amountPerTokenId = 1;
        string memory _trait = "Hat";
        string[] memory _value = _generateValues();
        uint256 _mintingFee = 100 * 1e18;
        uint256 _gateAmount = 10;
        uint16 _ercGateType = 20;
        uint16 _royalty = 5000; // now 0-10000
        string memory _imageURL = "https://ipfs.io/ipfs/QmYs8NVxVdHsxGwA5g1vjzfZKQnHGwdHkf2SN97rVGyMtc/422.png";
        SVGBuilder.AccessoryCallData memory data;
        SVGBuilder.AccessoryMintingParams memory params;

        for (uint256 i; i < _amount; i++) {
            data = _createAccessoryCallDataStruct(i, _totalSupply, 0, _amountPerTokenId, _trait, _value[i]);
            params = _createAccessoryMintingParamsStruct(
                address(accessories),
                i,
                _mintingFee,
                _gateAmount,
                address(degen),
                address(degen),
                _ercGateType,
                _royalty
            );

            _addAccessory(_imageURL, data, params);
            _checkAllStructs(i, data, params);
        }
        _checkAccessoryCount();
    }

    function _checkAllStructs(
        uint256 _accessoryId,
        SVGBuilder.AccessoryCallData memory _data,
        SVGBuilder.AccessoryMintingParams memory _params
    ) internal {
        // Destructuring the tuples to compare fields directly
        (
            uint256 accessoryIdReturned,
            uint256 _totalSupply,
            uint256 _amountMinted,
            uint256 _amountPerTokenId,
            string memory _traitType,
            string memory _value
        ) = based.accessoryData(_accessoryId);

        (
            address accessoryNFTCollection,
            uint256 _tokenId,
            uint256 _mintingFee,
            uint256 _gateAmount,
            address _feeAddress,
            address _gateAddress,
            uint16 _ercGateType,
            uint16 _royalty
        ) = based.accessoryMintingParams(_accessoryId);

        // Comparing AccessoryCallData fields
        assertEq(_data.accessoryId, accessoryIdReturned);
        assertEq(_data.totalSupply, _totalSupply);
        assertEq(_data.amountMinted, _amountMinted);
        assertEq(_data.amountPerTokenId, _amountPerTokenId);
        assertEq(_data.traitType, _traitType);
        assertEq(_data.value, _value);

        // Comparing AccessoryMintingParams fields
        assertEq(_params.accessoryNFTCollection, accessoryNFTCollection);
        assertEq(_params.tokenId, _tokenId);
        assertEq(_params.mintingFee, _mintingFee);
        assertEq(_params.gateAmount, _gateAmount);
        assertEq(_params.feeAddress, _feeAddress);
        assertEq(_params.gateAddress, _gateAddress);
        assertEq(_params.ercGateType, _ercGateType);
        assertEq(_params.royalty, _royalty);
    }

    uint256 accessoryId;
    uint256 totalSupply;
    uint256 amountMinted; // Do i iterate up on this? Add to test
    uint256 amountPerTokenId;
    string traitType;
    string value;

    function _createAccessoryCallDataStruct(
        uint256 _accessoryId,
        uint256 _totalSupply,
        uint256 _amountMinted,
        uint256 _amountPerTokenId,
        string memory _traitType,
        string memory _value
    ) internal pure returns (SVGBuilder.AccessoryCallData memory) {
        SVGBuilder.AccessoryCallData memory accessoryCallData = SVGBuilder.AccessoryCallData({
            accessoryId: _accessoryId,
            totalSupply: _totalSupply,
            amountMinted: _amountMinted,
            amountPerTokenId: _amountPerTokenId,
            traitType: _traitType,
            value: _value
        });

        return accessoryCallData;
    }

    function _createAccessoryMintingParamsStruct(
        address _accessoryNFTCollection,
        uint256 _tokenId,
        uint256 _mintingFee,
        uint256 _gateAmount,
        address _feeAddress,
        address _gateAddress,
        uint16 _ercGateType,
        uint16 _royalty
    ) internal pure returns (SVGBuilder.AccessoryMintingParams memory) {
        SVGBuilder.AccessoryMintingParams memory mintingParams = SVGBuilder.AccessoryMintingParams({
            accessoryNFTCollection: _accessoryNFTCollection,
            tokenId: _tokenId,
            mintingFee: _mintingFee,
            gateAmount: _gateAmount,
            feeAddress: _feeAddress,
            gateAddress: _gateAddress,
            ercGateType: _ercGateType,
            royalty: _royalty
        });

        return mintingParams;
    }

    function _addAccessory(
        string memory imageURL,
        SVGBuilder.AccessoryCallData memory accessoryCallDataInput,
        SVGBuilder.AccessoryMintingParams memory mintingParamsInput
    ) internal {
        based.addAccessory(imageURL, accessoryCallDataInput, mintingParamsInput);
    }

    function _checkAccessoryCount() internal {
        assertEq(based.accessoryCount(), accessories.totalSupply());
    }

    function _generateValues() internal pure returns (string[] memory) {
        string[] memory values = new string[](5);
        values[0] = "Diamond";
        values[1] = "Gold";
        values[2] = "Silver";
        values[3] = "Gambling";
        values[4] = "A Top Hat";
        return values;
    }

    function _generateAccessoryWallets(uint16 amount) internal {
        address accessoryWalletAddress;
        uint256 degenBalance;
        for (uint256 i = 0; i < amount; i++) {
            accessoryWalletAddress = address(uint160(i + 1));
            accessoryWallets.push(accessoryWalletAddress);

            deal(accessoryWalletAddress, 1000 * 1e18);
            assertEq(address(accessoryWalletAddress).balance, 1000 * 1e18, "ETH balance does not match expected value");

            degen.transfer(accessoryWalletAddress, 1000 * 1e18);
            degenBalance = degen.balanceOf(accessoryWalletAddress);
            assertEq(degenBalance, 1000 * 1e18, "DEGEN balance does not match expected value");
        }
    }

    function _generateMintWallets(uint16 amount) internal {
        address mintWalletAddress;
        uint256 degenBalance;
        uint256 ogNFTBalance;
        uint256 id = 0;
        // add +1 because no address 0, then don't add 1 so we can add an accessory wallet
        for (uint256 i = accessoryWallets.length + 1; i < accessoryWallets.length + amount; i++) {
            mintWalletAddress = address(uint160(i));
            mintWallets.push(mintWalletAddress);

            deal(mintWalletAddress, 1000 * 1e18);
            assertEq(address(mintWalletAddress).balance, 1000 * 1e18, "ETH balance does not match expected value");

            degen.transfer(mintWalletAddress, 1000 * 1e18);
            degenBalance = degen.balanceOf(mintWalletAddress);
            assertEq(degenBalance, 1000 * 1e18, "DEGEN balance does not match expected value");

            tnng.transferFrom(address(this), mintWalletAddress, id);
            ogNFTBalance = tnng.balanceOf(mintWalletAddress);
            assertEq(ogNFTBalance, 1, "OG NFT balance does not match");
            id++;
        }
        address accessoryWallet = accessoryWallets[accessoryWallets.length - 1];
        tnng.transferFrom(address(this), accessoryWallet, id);
        ogNFTBalance = tnng.balanceOf(accessoryWallet);
        assertEq(ogNFTBalance, 1, "OG NFT balance does not match");
        mintWallets.push(accessoryWallet);

        assertEq(mintWallets.length, amount);
    }

    function _createAndMintAccessories(uint16 amount) internal {
        accessories = new AccessoriesTestERC721A("DEGEN HATS", "HATS");
        for (uint256 i = 0; i < amount; i++) {
            vm.prank(address(accessoryWallets[i]));
            accessories.mint();
        }
        _checkAccessoryBalances(5, 1); // asserts accessory balances are correct
    }

    function _checkAccessoryBalances(uint16 amountWallets, uint8 amountAccessories) internal {
        for (uint256 i = 0; i < amountWallets; i++) {
            assertEq(
                accessories.balanceOf(accessoryWallets[i]),
                amountAccessories,
                "NFT balance does not match expected value"
            );
        }
    }
}
