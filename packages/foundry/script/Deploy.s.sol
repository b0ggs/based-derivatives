//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { BasedDerivatives } from "../contracts/BasedDerivitives/BasedDerivatives.sol";
import "./DeployHelpers.s.sol";
// import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        BasedDerivatives basedDerivitives = new BasedDerivatives(
            "Based Derivitives",
            "BASED",
            payable(deployer)
        );
        // address proxy = Upgrades.deployUUPSProxy(
        //     "YourContract.sol",
        //     abi.encodeCall(YourContract.initialize, (vm.addr(1)))
        // );

        // YourContract yourContract = new YourContract(
        //     vm.addr(deployerPrivateKey)
        // );
        console.logString(
            string.concat(
                "BasedDerivatives deployed at: ",
                vm.toString(address(basedDerivitives))
                // "YourContract proxy deployed at: ",
                // vm.toString(address(proxy))
            )
        );
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
