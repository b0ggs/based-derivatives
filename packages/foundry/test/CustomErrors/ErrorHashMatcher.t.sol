// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/console.sol";

//forge test --match-path test/CustomErrors/ErrorHashMatcher.t.sol --via-ir
contract ErrorHashMatcher is Test {
    // List the custom errors
    string[] public errors = [
        "NotOwner()",
        "NonExistentToken()",
        "InvalidAccessory()",
        "AccessoryURLAlreadySet()",
        "InvalidTokenType()",
        "NotEnoughGateToken()",
        "WrongParamData()",
        "NotEnoughPayment()",
        "AccessoriesMustUseSamePayment()",
        "AccessoryLimitReached()",
        "TotalSupplyExceeded()"
    ];

    function testWriteErrors() external {
        string memory outputFile = "test/CustomErrors/ErrorHashes.csv"; // Specify the path
        // Write the header to the CSV
        vm.writeFile(outputFile, "Error Signature,Hash\n");

        for (uint256 i = 0; i < errors.length; i++) {
            bytes4 hash = bytes4(keccak256(abi.encodePacked(errors[i])));
            // Create the CSV line
            string memory line = string(abi.encodePacked("\"", errors[i], "\",\"", toHexString(hash), "\"\n"));
            // Append the line to the file
            vm.writeLine(outputFile, line);
        }
    }

    // Helper function to convert bytes4 to a hex string
    function toHexString(bytes4 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(8);
        for (uint256 i = 0; i < 4; i++) {
            str[i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[1 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
