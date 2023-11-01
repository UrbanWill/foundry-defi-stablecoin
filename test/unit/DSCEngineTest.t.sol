// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract DSCEngineTest is Test {
    //////////////////
    // Errors       //
    //////////////////
    error DSCEngine__NeedsMoreThanZero();

    DSCEngine public dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig public config;

    address public ethUsdPriceFeed;
    address public btcUsdPriceFeed;
    address public weth;
    address public wbtc;

    uint256 amountCollateral = 10 ether;
    address public user = address(1);
    address public owner;

    ERC20Mock public wethToken;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() public {
        DeployDSC deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        config = config;
        (
            address ethUsdPriceFeedAddr,
            address btcUsdPriceFeedAddr,
            address wethAddr,
            address wbtcAddr,
            uint256 deployerKey
        ) = config.activeNetworkConfig();
        weth = wethAddr;
        wbtc = wbtcAddr;
        ethUsdPriceFeed = ethUsdPriceFeedAddr;
        btcUsdPriceFeed = btcUsdPriceFeedAddr;
        owner = vm.addr(deployerKey);

        wethToken = ERC20Mock(weth);

        ERC20Mock(weth).mint(user, STARTING_USER_BALANCE);
        ERC20Mock(wbtc).mint(user, STARTING_USER_BALANCE);
    }

    ///////////////////////
    // Constructor Tests //
    ///////////////////////
    address[] public tokenAddresses;
    address[] public feedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        tokenAddresses.push(weth);
        feedAddresses.push(ethUsdPriceFeed);
        feedAddresses.push(btcUsdPriceFeed);

        vm.expectRevert(DSCEngine.DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch.selector);
        new DSCEngine(tokenAddresses, feedAddresses, address(dsc));
    }

    //////////////////
    // Events       //
    //////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    //////////////////
    // Price Tests  //
    //////////////////

    function testGetUsdValue() public {
        uint256 ethAmount = 15e18;
        // 15e18 * 2000/ETH = 30,000e18
        uint256 expectedUsd = 30000e18;

        uint256 actual = dsce.getUsdValue(weth, ethAmount);

        assertEq(actual, expectedUsd);
    }

    //////////////////////////////
    // depositCollateral Tests  //
    //////////////////////////////

    function testRevertsdepositCollateralIfCollateralZero() public {
        vm.startPrank(user);
        ERC20Mock(weth).approve(address(dsce), amountCollateral);

        vm.expectRevert(DSCEngine.DSCEngine__NeedsMoreThanZero.selector);
        dsce.depositCollateral(weth, 0);
        vm.stopPrank();
    }

    function testRevertDepositCollateralTransferFailEmits() public {
        uint256 amount = 1e18;
        vm.expectRevert("ERC20: insufficient allowance");
        dsce.depositCollateral(weth, amount);
    }

    function testDepositCollateralUpdatesStorage() public {
        // Arrange
        vm.startPrank(user);
        wethToken.approve(address(dsce), amountCollateral);

        // Act
        dsce.depositCollateral(weth, amountCollateral);
        vm.stopPrank();

        // Assert
        uint256 expected = dsce.getUsdValue(weth, amountCollateral);
        uint256 actualCollateral = dsce.getAccountCollateralValue(user);

        assertEq(actualCollateral, expected);
    }

    function testDepositCollateralUpdatesEmits() public {
        // Arrange
        vm.startPrank(user);
        wethToken.approve(address(dsce), amountCollateral);

        // Act
        vm.expectEmit(true, true, false, true, address(dsce));
        emit CollateralDeposited(user, weth, amountCollateral);
        dsce.depositCollateral(weth, amountCollateral);
        vm.stopPrank();
    }
}
