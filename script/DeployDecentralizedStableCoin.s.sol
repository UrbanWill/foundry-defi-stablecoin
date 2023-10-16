// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {Script} from "forge-std/Script.sol";

contract DeployDecentralizedStableCoin is Script {
    function run() external returns (DecentralizedStableCoin) {
        vm.startBroadcast();
        DecentralizedStableCoin dcs = new DecentralizedStableCoin(msg.sender);
        vm.stopBroadcast();

        return dcs;
    }
}
