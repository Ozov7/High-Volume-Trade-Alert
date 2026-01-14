// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Trap} from "drosera-contracts/Trap.sol";


contract HighVolumeTradeAlert is Trap {

    address public constant TOKEN = address(0);
    address public constant POOL  = address(0);
    uint256 public constant VOLUME_THRESHOLD = 1_000 * 1e18;
    bytes32 public constant TRANSFER_TOPIC = keccak256("Transfer(address,address,uint256)");

    struct CollectOutput {
        uint256 tradeVolume;
        uint256 blockNumber;
    }

    constructor() {
        _addEventFilter(TOKEN, TRANSFER_TOPIC);
    }

    function collect()
        external
        view
        override
        returns (bytes memory)
    {
        uint256 sum = 0;

        Trap.Log[] memory logs = getFilteredLogs();

        for (uint256 i = 0; i < logs.length; i++) {
            // ERC20 Transfer has 3 indexed parameters: topic[0]=signature, topic[1]=from, topic[2]=to
            if (logs[i].topics.length < 3) continue;
            
            // Check this is a Transfer event
            if (logs[i].topics[0] != TRANSFER_TOPIC) continue;
            
            // Get from/to from topics (indexed parameters)
            address from = address(uint160(uint256(logs[i].topics[1])));
            address to = address(uint160(uint256(logs[i].topics[2])));
            
            // Get value from data (only non-indexed parameter)
            // Defensive check: data should be exactly 32 bytes for uint256
            if (logs[i].data.length != 32) continue;
            uint256 value = abi.decode(logs[i].data, (uint256));

            // Count transfers involving the pool
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
    

    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        // Planner-safety: guard against empty data
        if (data.length < 1 || data[0].length == 0) {
            return (false, bytes(""));
        }

        // Decode current block's data
        CollectOutput memory cur = abi.decode(data[0], (CollectOutput));

        // Check threshold
        if (cur.tradeVolume < VOLUME_THRESHOLD) {
            return (false, bytes(""));
        }

        
        if (data.length > 1 && data[1].length > 0) {
            CollectOutput memory prev = abi.decode(data[1], (CollectOutput));
            
            // If already above threshold last time, don't trigger again
            if (prev.tradeVolume >= VOLUME_THRESHOLD) {
                return (false, bytes(""));
            }
        }

        return (true, abi.encode(cur.tradeVolume));
    }
}
