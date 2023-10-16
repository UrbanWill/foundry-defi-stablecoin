// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployDecentralizedStableCoin} from "script/DeployDecentralizedStableCoin.s.sol";

contract DecentralizedStablecoinTest is Test {
    DecentralizedStableCoin dsc;
    DeployDecentralizedStableCoin deployer;

    function setUp() public {
        deployer = new DeployDecentralizedStableCoin();
        dsc = deployer.run();
    }

    function testConstroctuorDeployerIsOwner() public {
        assertEq(dsc.owner(), address(this));
    }
}
