// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployDecentralizedStableCoin} from "script/DeployDecentralizedStableCoin.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DecentralizedStablecoinTest is Test {
    DecentralizedStableCoin dsc;
    DeployDecentralizedStableCoin deployer;
    address public owner;
    HelperConfig helperConfig = new HelperConfig();

    function setUp() public {
        (,,,, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        owner = vm.addr(deployerKey);
        deployer = new DeployDecentralizedStableCoin();
        dsc = deployer.run();
    }

    function testConstroctuorDeployerIsOwner() public {
        assertEq(dsc.owner(), owner);
    }
}
