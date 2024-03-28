// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base64} from "../1099/Base64.sol";

/// @title SVG Builder for NFTs
/// @notice Provides functionalities to generate SVG images and metadata for NFTs, including handling of original NFT images and accessories.
library SVGBuilder {
    // Structs
    //TODO this is build in the front end based on the NFT user selects

    /// @dev Represents the original NFT image data, including ERC type and dimensions.
    struct ogImageData {
        address collection; //
        uint256 tokenId;
        uint16 ercType; //721 or 1155 Alchemy should tell us this
        string imageURL; // non-verifiable
        uint16 height;
        uint16 width;
    }

    /// @dev Defines an accessory's details to overlay on an NFT image.
    struct Accessory {
        uint256 accessoryId;
        string imageURL;
        uint16 height;
        uint16 width;
        uint16 x;
        uint16 y;
        bool isVisible;
    }

    /// @dev Since a mapping cannot go into calldata we send everything else and add the mapping later
    struct AccessoryCallData {
        uint256 accessoryId;
        uint256 totalSupply;
        uint256 amountMinted; // Do i iterate up on this? Add to test
        uint256 amountPerTokenId;
        string traitType;
        string value;

    }

    /// @dev Stores detailed information about an accessory, including its minting and usage stats.
    struct AccessoryData {
        uint256 accessoryId;
        uint256 totalSupply;
        uint256 amountMinted; // Do i iterate up on this? Add to test
        uint256 amountPerTokenId; // review this change
        mapping (uint256 => uint256) tokenIdtoAccessAmount;
        string traitType;
        string value;
    }

    /// @dev Parameters for minting an accessory, including payment and gating information.
    struct AccessoryMintingParams {
        address accessoryNFTCollection; //only ERC721 // accessory Data
        uint256 tokenId; //accessory data
        uint256 mintingFee;
        uint256 gateAmount; // if this is not set to 0 for not gate it will revert
        address feeAddress; // ERC20 that is paid
        address gateAddress;
        uint16 ercGateType; //20 721 1155 do not set if no gate
        uint16 royalty; // must be between 0 & 10000
    }

    /// @dev Holds the combined data of an NFT, including its original image and added accessories.
    struct TokenData {
        ogImageData ogImage;
        Accessory[] accessories;
        string previewImageURL;
    }

    /// @dev Defines a payout structure for transactions involving NFT minting.
    struct Payout {
        address recipient;
        uint256 amount;
    }

    // PUBLIC FUNCTIONS

    /// @notice Generates SVG image and metadata for an NFT, including accessories and ownership checks.
    /// @param tokenId The ID of the NFT for which to generate SVG and metadata.
    /// @param _tokenData Struct containing data about the NFT's original image and accessories.
    /// @param accessoriesCallData Array of accessory data to include in the NFT metadata.
    /// @param isOwner A flag indicating if the caller is the owner of the original NFT.
    /// @return A string of the final token URI with SVG image and metadata encoded in Base64.
    function generateSVG(
        uint256 tokenId,
        TokenData memory _tokenData,
        SVGBuilder.AccessoryCallData[] memory accessoriesCallData,
        bool isOwner
    ) public pure returns (string memory) {
        string memory svg;
        if(isOwner){
            // Convert dimensions to string
            string memory heightStr = _toString(_tokenData.ogImage.height);
            string memory widthStr = _toString(_tokenData.ogImage.width);

            // Start the SVG tag with the canvas size set to the dimensions of the ogImage
            svg = string(
                abi.encodePacked(
                    '<svg fill="none" height="',
                    heightStr,
                    'px" width="',
                    widthStr,
                    'px" xmlns="http://www.w3.org/2000/svg">',
                    '<image height="',
                    heightStr,
                    'px" width="',
                    widthStr,
                    'px" y="0" x="0" href="',
                    _tokenData.ogImage.imageURL,
                    '"></image>'
                )
            );
        } else {
            svg = _generateErrorSVG();
        }

        // Loop through each accessory and add it to the SVG
        for (uint256 i = 0; i < _tokenData.accessories.length; i++) {
            Accessory memory accessory = _tokenData.accessories[i];
            if(accessory.isVisible){
                svg = string(
                    abi.encodePacked(
                        svg,
                        '<image preserveAspectRatio="none" height="',
                        _toString(accessory.height),
                        'px" width="',
                        _toString(accessory.width),
                        'px" y="',
                        _toString(accessory.y),
                        '" x="',
                        _toString(accessory.x),
                        '" href="',
                        accessory.imageURL,
                        '"></image>'
                    )
                );
            }
        }

        // Close the SVG tag
        svg = string(abi.encodePacked(svg, "</svg>"));

        bytes memory svgBytes = bytes(svg);
        string memory base64Svg = Base64.encode(svgBytes);
        string memory animation = string(abi.encodePacked("data:image/svg+xml;base64,", base64Svg));

        //   AccessoryData[] memory accessoriesData = _getAccessoryData(_tokenData.accessories);
        string memory attributes = _generateAttributes(accessoriesCallData);

        string memory json = string(
            abi.encodePacked(
                '{"name": "Token #',
                _toString(tokenId),
                '", "description": "A Based Derivative", "attributes": ',
                attributes,
                ', "animation_url": "',
                animation,
                '", "image": "',
                _tokenData.previewImageURL,
                '"}'
            )
        );


        string memory base64Json = Base64.encode(bytes(json));
        string memory finalTokenURI = string(abi.encodePacked("data:application/json;base64,", base64Json));

        return finalTokenURI;
    }

    //INTERNAL FUNCTIONS

    /// @dev Generates JSON attributes for each accessory to include in the NFT metadata.
    /// @param accessoriesCallData Array of accessory data to convert into JSON attributes.
    /// @return A JSON string of all attributes for the accessories.
    function _generateAttributes(AccessoryCallData[] memory accessoriesCallData) internal pure returns (string memory) {
        string memory attributesJson = "[";
        for (uint256 i = 0; i < accessoriesCallData.length; i++) {
            AccessoryCallData memory data = accessoriesCallData[i];

            attributesJson = string(
                abi.encodePacked(attributesJson, '{"trait_type": "', data.traitType, '", "value": "', data.value, '"}')
            );

            if (i < accessoriesCallData.length - 1) {
                attributesJson = string(abi.encodePacked(attributesJson, ", "));
            }
        }
        attributesJson = string(abi.encodePacked(attributesJson, "]"));
        return attributesJson;
    }


    /// @dev Generates an SVG error message when the original NFT is no longer owned by the derivative NFT creator.
    /// @return A string containing the SVG error message.
    function _generateErrorSVG() internal pure returns (string memory) {
        return '<svg width="660" height="600" xmlns="http://www.w3.org/2000/svg">'
            '<style>.text { font: bold 75px sans-serif; fill: red; }</style>'
            '<rect width="100%" height="100%" fill="white"/>'
            '<text x="10" y="75" class="text">Your original NFT longer in the same wallet</text>'
            '<text x="10" y="140" class="text">is no longer in the</text>'
            '<text x="10" y="215" class="text">same wallet as</text>'
            '<text x="10" y="285" class="text">this NFT. Please</text>'
            '<text x="10" y="355" class="text">set new original</text>'
            '<text x="10" y="425" class="text">NFT.</text>'
            '</svg>';
    }

    /// @dev Converts a uint256 to a string.
    /// @param value The uint256 value to convert.
    /// @return str The string representation of the input value.
    function _toString(uint256 value) internal pure returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}
