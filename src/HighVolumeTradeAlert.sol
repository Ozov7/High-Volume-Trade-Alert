// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Trap} from "drosera-contracts/Trap.sol";

interface IERC20Metadata {
    function decimals() external view returns (uint8);
}


contract HighVolumeTradeAlert is Trap {

    address public constant TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    address public constant POOL  = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc; // Uniswap V2 WETH/USDC
    
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
            
            if (prev.tradeVolume >= VOLUME_THRESHOLD) {
                return (false, bytes(""));
            }
        }

        return (true, abi.encode(cur.tradeVolume));
    }
}
