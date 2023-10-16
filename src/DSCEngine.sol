// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title DSCEngine
 * @author Will Urban
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is very loosely based on the MakerDAO DSS system
 */
contract DSCEngine is ReentrancyGuard {
    //////////////////
    // Errors       //
    //////////////////
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedsAddressesMustBeSameLength();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();

    ////////////////////////
    // State Variables    //
    ////////////////////////
    DecentralizedStableCoin private immutable i_dsc;

    /// @dev Mapping of token address to price feed address
    mapping(address token => address priceFeed) private s_priceFeeds;
    /// @dev Mapping of users to collateral balances by token
    mapping(address user => mapping(address token => uint256 balance)) s_collateralDeposited;

    //////////////////
    // Events       //
    //////////////////
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    //////////////////
    // Modifiers    //
    //////////////////
    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowendToken(address tokenAddress) {
        if (s_priceFeeds[tokenAddress] == address(0)) {
            revert DSCEngine__TokenNotAllowed(tokenAddress);
        }
        _;
    }

    //////////////////
    // Functions    //
    //////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedsAddressesMustBeSameLength();
        }
        // These feeds will be the USD pairs
        // For example ETH / USD or MKR / USD
        uint256 addressesLength = tokenAddresses.length;
        for (uint256 i = 0; i < addressesLength; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }

        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    ///////////////////////////
    // External Functions    //
    ///////////////////////////

    function depositCollateralAndMintSc() external {}

    /**
     *
     * @param tokenCollateralAddress The address of the collateral token to deposit
     * @param amountCollateral The amount of collateral to deposit
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowendToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = ERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external {}
}
