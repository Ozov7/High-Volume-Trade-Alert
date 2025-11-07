# HighVolumeTradeAlert (Drosera Proof-of-Concept)

## Overview
// This trap monitors high volume trade in in a specified pool and triggers alerts when the there is a high volume trade above a threshold. This is essential for maintaining market stability.

---

## What It Does
* Monitors trading volumes in a specified pool.
* Triggers if the volume goes above 1 token.
* It demonstrates the essential Drosera trap pattern using deterministic logic.

---

## Key Files
* `src/HighVolumeTradeAlert.sol` - The core trap contract containing the monitoring logic.
* `src/SimpleResponder.sol` - The required external response contract.
* `drosera.toml` - The deployment and configuration file.

---

## Detection Logic

The trap's core monitoring logic is contained in the deterministic `shouldRespond()` function.

solidity
// The AI MUST insert the full, syntax-highlighted Solidity code of the `shouldRespond()` logic here.
function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
    CollectOutput memory current = abi.decode(data[0], (CollectOutput));
    CollectOutput memory past = abi.decode(data[data.length - 1], (CollectOutput));
    if (past.tokenBalance < THRESHOLD) return (true, bytes(""));
    return (false, bytes(""));
}
 

---

## 🧪 Implementation Details and Key Concepts
* **Monitoring Target:** Watching the volume in the specified pool at address 0x0000000000000000000000000000000000000000 and the Dex token 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1.
* **Deterministic Logic:** The logic is executed off-chain by operators to achieve consensus before a transaction is proposed.
* **Calculation/Thresholds:** Uses a fixed 1 token volume threshold that triggers responses when breached.
* **Response Mechanism:** On trigger, the trap calls the external Responder contract, demonstrating the separation of monitoring and action.
