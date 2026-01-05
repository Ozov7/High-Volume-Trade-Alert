// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HighVolumeTradeAlert} from "../src/HighVolumeTradeAlert.sol";

contract DeployHighVolumeTradeAlert is Script {
    function run() public {
        vm.startBroadcast();

        // 🔴 REPLACE with the real pool address you want to monitor
        address pool = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;

        new HighVolumeTradeAlert(pool);

        vm.stopBroadcast();
    }
}

