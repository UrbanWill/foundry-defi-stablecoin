// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployDecentralizedStableCoin is Script {
    HelperConfig helperConfig = new HelperConfig();

    function run() external returns (DecentralizedStableCoin) {
        (,,,, uint256 deployerKey) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin dcs = new DecentralizedStableCoin();
        vm.stopBroadcast();

        return dcs;
    }
}
