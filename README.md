# HighVolumeTradeAlert (Drosera Proof-of-Concept)

## Overview
This trap monitors high-volume trades in a specified pool and triggers alerts when trade volume exceeds a configurable threshold.  
It demonstrates a Drosera trap pattern for maintaining market stability by detecting spikes in token flow.

---

## What It Does
* Monitors **actual token transfers** in a specified pool using ERC20 Transfer events.
* Triggers when trade volume exceeds a defined threshold (configured in token base units).
* Implements **planner safety** with empty-blob guards to prevent decode reverts.
* Uses **hardcoded addresses** for Drosera compatibility (zero-argument constructor).
* Demonstrates Drosera trap pattern: separation of monitoring and response logic.
* Includes **rising-edge detection** to prevent repeated triggers.

---

## Key Files
* `src/HighVolumeTradeAlert.sol` - The core trap contract with fixed event decoding and ABI-safe response logic.
* `src/SimpleResponder.sol` - External response contract with proper uint256 signature.
* `drosera.toml` - Deployment and configuration file with Foundry remappings.
* `foundry.toml` - Foundry configuration with drosera-contracts dependencies.

---

## Detection Logic

### Core Monitoring (`collect()` function)
The trap correctly decodes ERC20 Transfer events:
```solidity

if (logs[i].topics.length < 3) continue;
if (logs[i].topics[0] != TRANSFER_TOPIC) continue;

address from = address(uint160(uint256(logs[i].topics[1])));
address to = address(uint160(uint256(logs[i].topics[2])));


if (logs[i].data.length != 32) continue;
uint256 value = abi.decode(logs[i].data, (uint256));
