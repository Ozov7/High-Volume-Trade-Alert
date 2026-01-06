# HighVolumeTradeAlert (Drosera Proof-of-Concept)

## Overview
This trap monitors high-volume trades in a specified pool and triggers alerts when there is a trade above a threshold.  
It demonstrates a Drosera trap pattern for maintaining market stability by detecting spikes in token flow.

---

## What It Does
* Monitors **actual token transfers** in a specified pool using ERC20 Transfer events.
* Triggers if trade volume goes above a defined threshold (scaled to 18 decimals).
* Implements **planner safety** with empty-blob guards.
* Uses a constructor to configure POOL and TOKEN addresses instead of hardcoded values.
* Demonstrates Drosera trap pattern: separation of monitoring and response logic.

---

## Key Files
* `src/HighVolumeTradeAlert.sol` - The core trap contract containing the monitoring logic, decimals scaling, and event-based trade volume detection.
* `src/SimpleResponder.sol` - The required external response contract.
* `drosera.toml` - Deployment and configuration file with Foundry remappings for Drosera contracts.

---

## Detection Logic

The trap's core monitoring logic is in `shouldRespond()`. It compares the current and past trade volume and triggers when the change exceeds the threshold.

```solidity
function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
    // 🔐 Planner-safety guard
    if (data.length < 2 || data[0].length == 0 || data[data.length - 1].length == 0) {
        return (false, "");
    }

    CollectOutput memory current = abi.decode(data[0], (CollectOutput));
    CollectOutput memory past = abi.decode(data[data.length - 1], (CollectOutput));

    if (past.tradeVolume == 0) return (false, "");

    uint256 change = current.tradeVolume > past.tradeVolume
        ? current.tradeVolume - past.tradeVolume
        : past.tradeVolume - current.tradeVolume;

    // 🔁 ABI-safe return
    if (change > 1e18) {
        return (true, abi.encode(change));
    }

    return (false, "");
}
