pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {HighVolumeTradeAlert, CollectOutput} from "../src/HighVolumeTradeAlert.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

contract HighVolumeTradeAlertTest is Test {

    HighVolumeTradeAlert public alert;
    address public pool = address(0x1234);     // replace with your real pool
    address public token = address(0xABCD);    // replace with real token

    function scale(uint256 raw, uint8 dec)
        internal
        pure
        returns (uint256)
    {
        return dec < 18
            ? raw * (10 ** (18 - dec))
            : raw / (10 ** (dec - 18));
    }

    function setUp() public {
        alert = new HighVolumeTradeAlert(pool);
    }

    function test_DecimalScaling() public {

        uint8 dec = IERC20(token).decimals();
        uint256 raw = IERC20(token).balanceOf(pool);

        bytes memory result = alert.collect();

        CollectOutput memory out =
            abi.decode(result, (CollectOutput));

        uint256 expected = scale(raw, dec);

        assertEq(out.tradeVolume, expected);
    }
}

forge test
