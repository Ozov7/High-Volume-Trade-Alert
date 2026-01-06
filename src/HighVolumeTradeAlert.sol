// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

import {Trap} from "drosera-contracts/Trap.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract HighVolumeTradeAlert is Trap {

    address public immutable TOKEN;
    address public immutable POOL;

    struct CollectOutput {
        uint256 tradeVolume;
        uint256 blockNumber;
    }

    constructor(address token, address pool) {
        TOKEN = token;
        POOL  = pool;

        _addEventFilter(
            address(TOKEN),
            IERC20.Transfer.selector
        );
    }

    function collect()
        external
        view
        override
        returns (bytes memory)
    {
        uint256 sum = 0;

        Trap.Log[] memory logs =
            getFilteredLogs();

        for (uint256 i = 0; i < logs.length; i++) {

            (address from, address to, uint256 value) =
                abi.decode(
                    logs[i].data,
                    (address,address,uint256)
                );

            if (from == POOL || to == POOL) {
                sum += value;
            }
        }

        return abi.encode(
            CollectOutput({
                tradeVolume: sum,
                blockNumber: block.number
            })
        );
    }
}
