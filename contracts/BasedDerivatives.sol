// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721A} from "../1099/ERC721A.sol";
import {Ownable} from "../1099/Ownable.sol";
import {SVGBuilder} from "./SVGBuilder.sol";
import {ERC20} from "../1099/ERC20.sol";
import {SafeTransferLib} from "../1099/SafeTransferLib.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256 balance);
}

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

//TODO
// Add events

/// @title Base →D[erivatives] an exploration of Remix Culture
/// @dev Implements ERC721A for efficient batch minting and Ownable for administrative controls
contract BasedDerivatives is ERC721A, Ownable {
    using SafeTransferLib for ERC20;
    using SafeTransferLib for address payable;
    using SVGBuilder for SVGBuilder.Accessory;
    using SVGBuilder for SVGBuilder.ogImageData;
    using SVGBuilder for SVGBuilder.TokenData;
    using SVGBuilder for SVGBuilder.AccessoryData;
    using SVGBuilder for SVGBuilder.AccessoryMintingParams;
    using SVGBuilder for SVGBuilder.Payout;
    using SVGBuilder for SVGBuilder.AccessoryCallData;

    // State Variables
    /// @notice Count of all accessories added for front end query
    uint256 public accessoryCount = 0;
    /// @notice Beneficiary address for receiving payments
    address payable beneficiary;

    // Mappings
    mapping(uint256 => string) public accessoryImageURL; // TODO FRONT_END - query for image
    mapping(uint256 => SVGBuilder.TokenData) public tokenData;
    mapping(uint256 => SVGBuilder.AccessoryData) public accessoryData; // TODO FRONT_END - query that amountMinted < totalSupply, or else remove accessory
    mapping(uint256 => SVGBuilder.AccessoryMintingParams) public accessoryMintingParams; // TODO FRONT_END - query does user have enough gateToken & mintToken? If not grayOut

    // Events
    event MetadataUpdate(uint256 _tokenId);

    // Errors
    error NotOwner();
    error NonExistentToken();
    error InvalidAccessory();
    error AccessoryURLAlreadySet();
    error InvalidTokenType();
    error NotEnoughGateToken();
    error WrongParamData();
    error NotEnoughPayment();
    error AccessoriesMustUseSamePayment();
    error AccessoryLimitReached();
    error TotalSupplyExceeded();

    /// @notice Constructs the BasedDerivatives contract
    /// @param name The name of the NFT collection
    /// @param symbol The symbol of the NFT collection
    /// @param _beneficiary The address that will receive payments
    constructor(string memory name, string memory symbol, address payable _beneficiary)
        ERC721A(name, symbol)
        Ownable(msg.sender)
    {
        beneficiary = _beneficiary;
    }

    //EXTERNAL FUNCTIONS
    /// @notice Updates the address eligible to receive payments
    /// @param _beneficiary The new beneficiary's address
    function updatePayableAddy(address payable _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
    }

    //TODO: what happens if we make an SVG with IPFS: instead of a gateway?

    /// @notice Adds a new accessory to be used in NFTs, onlyOwner
    /// @param imageURL URL of the accessory image
    /// @param accessoryDataInput Data for the new accessory
    /// @param mintingParamsInput Minting parameters for the accessory
    function addAccessory(
        string calldata imageURL, //ipfs:url
        SVGBuilder.AccessoryCallData calldata accessoryDataInput,
        SVGBuilder.AccessoryMintingParams calldata mintingParamsInput
    ) public onlyOwner {
        uint256 accessoryId = accessoryDataInput.accessoryId;

        if (bytes(accessoryImageURL[accessoryId]).length != 0) revert AccessoryURLAlreadySet();

        accessoryImageURL[accessoryId] = imageURL;
        accessoryMintingParams[accessoryId] = mintingParamsInput;
        _populateAccessoryData(accessoryId, accessoryDataInput);

        accessoryCount++;
    }

    // NOTE A new accessory needs to be added in case the old accessory was minted.
    // In the case where you want to permanently remove the accessory make
    //totalSupply of the accessoryData 0

    /// @notice Removes an existing accessory and adds a new one, onlyOwner
    /// @param accessoryId ID of the accessory to replace
    /// @param imageURL URL of the new accessory image
    /// @param accessoryDataInput Data for the new accessory
    /// @param mintingParamsInput Minting parameters for the new accessory
    function deleteAndAddAccessory(
        uint256 accessoryId,
        string calldata imageURL, //ipfs:url
        SVGBuilder.AccessoryCallData calldata accessoryDataInput,
        SVGBuilder.AccessoryMintingParams calldata mintingParamsInput
    ) external onlyOwner {
        delete accessoryImageURL[accessoryId];
        delete accessoryData[accessoryId];
        delete accessoryMintingParams[accessoryId];

        addAccessory(imageURL, accessoryDataInput, mintingParamsInput);
    }

    // We should pass an ipfs address for the image url and keep svg as an animation url
    // ADD IPFS image for OS preview image

    /// @notice Mints a new derivative NFT with specified original NFT data and accessories
    /// @param _ogImage The original NFT data including its collection, token ID, and image details
    /// @param _accessories Array of accessories to include in the minted NFT
    /// @param _previewImageURL The ipfs URL for the OS image preview
    function mintBasedDerivative(
        SVGBuilder.ogImageData calldata _ogImage,
        SVGBuilder.Accessory[] calldata _accessories,
        string calldata _previewImageURL
    ) external {
        _verifyNFTownership(_ogImage);
        uint256 tokenId = _nextTokenId();
        _verifyAccessoryData(tokenId, _accessories);
        address mintFeeAddress = _checkSameMintFeeAddress(_accessories);
        (uint256 totalFee, address toPayWith) = getTotalFeeForAccessories(_accessories);
        if (ERC20(mintFeeAddress).balanceOf(msg.sender) < totalFee) revert NotEnoughPayment();
        _mint(msg.sender, 1);

        // Set the ogImageURL for the new token
        SVGBuilder.TokenData storage newTokenData = tokenData[tokenId];
        newTokenData.ogImage = _ogImage;
        newTokenData.accessories = _accessories;
        newTokenData.previewImageURL = _previewImageURL;

        if (totalFee > 0) _handlePayment(_accessories, toPayWith);
    }

    //ALSO update OS preview image
    //TODO the accessories[] must be in the same order as existingTokenData.accessories

    /// @notice Edits an existing derivative NFT to move its accessories
    /// @param tokenId The ID of the derivative NFT to edit
    /// @param accessories New array of accessories for the NFT, must match old accessories in same order but can have new x,y,width,height,isVisible
    /// @param _previewImageURL The ipfs URL for the OS image preview
    function editBasedDerivative(
        uint256 tokenId,
        SVGBuilder.Accessory[] calldata accessories,
        string calldata _previewImageURL
    ) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();

        SVGBuilder.TokenData storage existingTokenData = tokenData[tokenId];

        _verifyAccessoryMatch(existingTokenData.accessories, accessories);

        // TODO test with and without delete. How does this work at the evm level
        //  delete existingTokenData.accessories;
        existingTokenData.accessories = accessories;
        existingTokenData.previewImageURL = _previewImageURL;
    }

    // Note we don't verify that the old ogImage matches the new but we do verify
    // that the msg.sender is the owner of the new ogImage

    /// @notice Updates the original NFT image associated with a derivative NFT
    /// @param tokenId The ID of the derivative NFT to update
    /// @param _ogImage New original NFT data to associate with the derivative
    /// @param _previewImageURL The ipfs URL for the OS image preview
    function editOGImage(uint256 tokenId, SVGBuilder.ogImageData calldata _ogImage, string calldata _previewImageURL)
        external
    {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        _verifyNFTownership(_ogImage);

        SVGBuilder.TokenData storage existingTokenData = tokenData[tokenId];

        existingTokenData.ogImage = _ogImage;
        existingTokenData.previewImageURL = _previewImageURL;
    }

    /// @notice Adds additional accessories to an existing derivative NFT
    /// @param tokenId The ID of the derivative NFT to modify
    /// @param _accessories Array of new accessories to add to the NFT, must still contain the old accessories in the same order
    /// @param _previewImageURL The ipfs URL for the OS image preview
    function addAccessoriesToDerivative(
        uint256 tokenId,
        SVGBuilder.Accessory[] calldata _accessories,
        string calldata _previewImageURL
    ) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        _verifyAccessoryData(tokenId, _accessories);
        address mintFeeAddress = _checkSameMintFeeAddress(_accessories);
        (uint256 totalFee, address toPayWith) = getTotalFeeForAccessories(_accessories);
        if (ERC20(mintFeeAddress).balanceOf(msg.sender) < totalFee) revert NotEnoughPayment();

        SVGBuilder.TokenData storage existingTokenData = tokenData[tokenId];

        // Append new accessories to the existing array
        for (uint256 i = 0; i < _accessories.length; i++) {
            existingTokenData.accessories.push(_accessories[i]);
        }
        existingTokenData.previewImageURL = _previewImageURL;

        if (totalFee > 0) _handlePayment(_accessories, toPayWith);
    }

    //TODO this has no revert for an incorrect accessoryId do we need that? If yes we could include a count and revert if 0
    /// @notice Toggles the visibility of an accessory on a derivative NFT
    /// @param tokenId The ID of the derivative NFT to modify
    /// @param _accessoryId The ID of the accessory to toggle
    /// @param _isVisible New visibility state of the accessory
    /// @param _previewImageURL The ipfs URL for the OS image preview
    function toggleAccessoryOnOff(
        uint256 tokenId,
        uint256 _accessoryId,
        bool _isVisible,
        string calldata _previewImageURL
    ) external {
        if (ownerOf(tokenId) != msg.sender) revert NotOwner();
        SVGBuilder.TokenData storage existingTokenData = tokenData[tokenId];
        SVGBuilder.Accessory[] storage _accessories = existingTokenData.accessories;

        for (uint256 i = 0; i < _accessories.length; i++) {
            if (_accessories[i].accessoryId == _accessoryId) {
                _accessories[i].isVisible = _isVisible;
            }
        }

        existingTokenData.previewImageURL = _previewImageURL;
    }

    // Public Functions
    /// @notice Calculates total fees for minting with specified accessories, accessories must have same payment token
    /// @param accessories Array of accessories to calculate fees for
    /// @return totalCost Total cost for the specified accessories
    /// @return toPayWith Address of the ERC20 token to use for payment
    function getTotalFeeForAccessories(SVGBuilder.Accessory[] calldata accessories)
        public
        view
        returns (uint256, address)
    {
        address toPayWith = _checkSameMintFeeAddress(accessories);
        uint256 totalCost = _calculateTotalFee(accessories);
        return (totalCost, toPayWith);
    }

    //TODO If else function that checks that the owner still owns the OG NFT or else it displays
    // text in the background for the OG image.

    /// @notice Provides the metadata URI for a given token
    /// @dev Overrides ERC721A's tokenURI function to provide game-specific metadata
    /// @param tokenId The token ID to retrieve the URI for
    /// @return The metadata URI for the token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();
        SVGBuilder.TokenData memory newTokenData = tokenData[tokenId];
        SVGBuilder.AccessoryCallData[] memory accessoriesCallData = _getAccessoryData(newTokenData.accessories);
        bool isOwner = _verifyOGandDerivownership(newTokenData.ogImage, tokenId);
        (string memory finalTokenURI) = SVGBuilder.generateSVG(tokenId, newTokenData, accessoriesCallData, isOwner);

        return finalTokenURI;
    }

    // INTERNAL FUNCTIONS
    /// @dev Verifies ownership of the NFT specified in ogImageData
    /// @param _ogImage Data of the original NFT
    /// @param _tokenId Token ID of the derivative NFT
    /// @return bool True if the original NFT is owned by the caller
    function _verifyOGandDerivownership(SVGBuilder.ogImageData memory _ogImage, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(_tokenId);
        if (_ogImage.ercType == 721) {
            IERC721 erc721Contract = IERC721(_ogImage.collection);
            if (erc721Contract.ownerOf(_ogImage.tokenId) != owner) return false;
            return true;
        } else if (_ogImage.ercType == 1155) {
            IERC1155 erc1155Contract = IERC1155(_ogImage.collection);
            if (erc1155Contract.balanceOf(owner, _ogImage.tokenId) == 0) return false;
            return true;
        } else {
            revert InvalidTokenType();
        }
    }

    /// @dev Matches new accessories with existing ones for a given NFT
    /// @param existingAccessories Array of current accessories for the NFT
    /// @param newAccessories Array of new accessories to be matched
    function _verifyAccessoryMatch(
        SVGBuilder.Accessory[] memory existingAccessories,
        SVGBuilder.Accessory[] calldata newAccessories
    ) internal view {
        if (newAccessories.length != existingAccessories.length) revert InvalidAccessory();

        string memory registeredURL;

        for (uint256 i = 0; i < newAccessories.length; i++) {
            if (newAccessories[i].accessoryId != existingAccessories[i].accessoryId) revert InvalidAccessory();

            registeredURL = accessoryImageURL[newAccessories[i].accessoryId];

            // Check if the URL in the struct matches the URL in the mapping
            if (keccak256(abi.encodePacked(newAccessories[i].imageURL)) != keccak256(abi.encodePacked(registeredURL))) {
                revert InvalidAccessory();
            }
        }
    }

    /// @dev Handles payment distribution for accessory minting
    /// @param accessories Array of accessories involved in the transaction
    /// @param toPayWith Address of the ERC20 token to be used for payment
    function _handlePayment(SVGBuilder.Accessory[] memory accessories, address toPayWith) internal {
        //    SVGBuilder.Payout[] memory payouts = new SVGBuilder.Payout[](accessories.length);
        uint256 totalBeneficiaryAmount;

        // Accumulate minting fees and prepare payouts
        for (uint256 i; i < accessories.length; i++) {
            uint256 accessoryId = accessories[i].accessoryId;
            SVGBuilder.AccessoryMintingParams memory params = accessoryMintingParams[accessoryId];

            if (params.mintingFee > 0) {
                address NFTOwner = IERC721(params.accessoryNFTCollection).ownerOf(params.tokenId);
                uint256 royaltyAmount = params.mintingFee * params.royalty / 10000;

                ERC20(toPayWith).safeTransferFrom(msg.sender, NFTOwner, royaltyAmount);

                totalBeneficiaryAmount += (params.mintingFee - royaltyAmount);
            }
        }

        ERC20(toPayWith).safeTransferFrom(msg.sender, beneficiary, totalBeneficiaryAmount);
    }

    /// @dev Retrieves accessory data for generating NFT metadata
    /// @param accessories Array of accessories to retrieve data for
    /// @return accessoriesCallData Array of accessory calldata used in NFT metadata
    function _getAccessoryData(SVGBuilder.Accessory[] memory accessories)
        internal
        view
        returns (SVGBuilder.AccessoryCallData[] memory)
    {
        SVGBuilder.AccessoryCallData[] memory accessoriesCallData =
            new SVGBuilder.AccessoryCallData[](accessories.length);
        for (uint256 i = 0; i < accessories.length; i++) {
            accessoriesCallData[i].accessoryId = accessoryData[i].accessoryId;
            accessoriesCallData[i].traitType = accessoryData[i].traitType;
            accessoriesCallData[i].value = accessoryData[i].value;
        }
        return accessoriesCallData;
    }

    /// @dev Populates accessoryData based on the AccessoryCallData
    /// @param accessoryId ID of the accessory to populate data for
    /// @param accessoryDataInput Data input for the accessory
    function _populateAccessoryData(uint256 accessoryId, SVGBuilder.AccessoryCallData calldata accessoryDataInput)
        internal
    {
        SVGBuilder.AccessoryData storage accessoryDataStorage = accessoryData[accessoryId];

        accessoryDataStorage.accessoryId = accessoryDataInput.accessoryId;
        accessoryDataStorage.totalSupply = accessoryDataInput.totalSupply;
        accessoryDataStorage.amountMinted = accessoryDataInput.amountMinted;
        accessoryDataStorage.amountPerTokenId = accessoryDataInput.amountPerTokenId;
        accessoryDataStorage.traitType = accessoryDataInput.traitType;
        accessoryDataStorage.value = accessoryDataInput.value;
    }

    /// @dev Verifies the data of accessories to be used in minting a derivative NFT
    /// @param tokenId ID of the NFT to verify accessories for
    /// @param accessories Array of accessories to be verified
    function _verifyAccessoryData(uint256 tokenId, SVGBuilder.Accessory[] calldata accessories) internal {
        for (uint256 i; i < accessories.length; i++) {
            SVGBuilder.Accessory calldata accessory = accessories[i];
            string memory registeredURL = accessoryImageURL[accessory.accessoryId];
            SVGBuilder.AccessoryData storage data = accessoryData[accessory.accessoryId];
            SVGBuilder.AccessoryMintingParams memory params = accessoryMintingParams[accessory.accessoryId];

            data.tokenIdtoAccessAmount[tokenId]++;
            data.amountMinted++;

            if (data.tokenIdtoAccessAmount[tokenId] > data.amountPerTokenId) revert AccessoryLimitReached();

            // Check if the URL in the struct matches the URL in the mapping
            if (keccak256(abi.encodePacked(accessory.imageURL)) != keccak256(abi.encodePacked(registeredURL))) {
                revert InvalidAccessory();
            }

            // Check if the accessory is still available
            if (data.amountMinted > data.totalSupply) revert TotalSupplyExceeded();

            // Check if msg.sender has enough balance to meet the gateAmount
            if (params.gateAmount > 0) {
                _checkGateAmount(params);
            }
        }
    }

    /// @dev Checks if the gate amount requirement for an accessory is met
    /// @param _params Minting parameters of the accessory including gate amount
    function _checkGateAmount(SVGBuilder.AccessoryMintingParams memory _params) internal view {
        if (_params.ercGateType == 20) {
            ERC20 gatingToken = ERC20(_params.gateAddress);
            uint256 senderBalance = gatingToken.balanceOf(msg.sender);
            if (senderBalance < _params.gateAmount) revert NotEnoughGateToken();
        } else if (_params.ercGateType == 721) {
            IERC721 gatingToken = IERC721(_params.gateAddress);
            uint256 senderBalance = gatingToken.balanceOf(msg.sender);
            if (senderBalance < _params.gateAmount) revert NotEnoughGateToken();
        } else if (_params.ercGateType == 1155) {
            IERC1155 gatingToken = IERC1155(_params.gateAddress);
            uint256 senderBalance = gatingToken.balanceOf(msg.sender, _params.tokenId);
            if (senderBalance < _params.gateAmount) revert NotEnoughGateToken();
        } else {
            revert WrongParamData();
        }
    }

    /// @dev Verifies the ownership of the original NFT used for creating a derivative
    /// @param _ogImage Data of the original NFT
    function _verifyNFTownership(SVGBuilder.ogImageData calldata _ogImage) internal view {
        if (_ogImage.ercType == 721) {
            IERC721 erc721Contract = IERC721(_ogImage.collection);
            if (erc721Contract.ownerOf(_ogImage.tokenId) != msg.sender) revert NotOwner();
        } else if (_ogImage.ercType == 1155) {
            IERC1155 erc1155Contract = IERC1155(_ogImage.collection);
            if (erc1155Contract.balanceOf(msg.sender, _ogImage.tokenId) == 0) revert NotOwner();
        } else {
            revert InvalidTokenType();
        }
    }

    /// @dev Calculates the total fee required for minting based on selected accessories
    /// @param accessories Array of accessories to calculate fees for
    /// @return totalFee Total fee for minting the selected accessories
    function _calculateTotalFee(SVGBuilder.Accessory[] memory accessories) internal view returns (uint256) {
        uint256 totalFee;
        for (uint256 i; i < accessories.length; i++) {
            uint256 accessoryId = accessories[i].accessoryId;
            SVGBuilder.AccessoryMintingParams memory params = accessoryMintingParams[accessoryId];
            totalFee += params.mintingFee;
        }
        return totalFee;
    }

    /// @dev Checks if all selected accessories use the same payment token type
    /// @param accessories Array of accessories to check
    /// @return mintFeeAddress The common token address used by all accessories, if applicable
    function _checkSameMintFeeAddress(SVGBuilder.Accessory[] memory accessories) internal view returns (address) {
        address mintFeeAddress;
        for (uint256 i = 0; i < accessories.length; i++) {
            uint256 accessoryId = accessories[i].accessoryId;
            SVGBuilder.AccessoryMintingParams memory params = accessoryMintingParams[accessoryId];
            if (params.feeAddress != address(0) && mintFeeAddress == address(0)) {
                mintFeeAddress = params.feeAddress;
            } else if (params.feeAddress != address(0) && mintFeeAddress != address(0)) {
                if (mintFeeAddress != params.feeAddress) revert AccessoriesMustUseSamePayment();
            }
        }
        return mintFeeAddress;
    }
}
