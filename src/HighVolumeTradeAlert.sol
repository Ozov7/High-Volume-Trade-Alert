// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/interfaces/ITrap.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract HighVolumeTradeAlert is ITrap {
    address public constant TOKEN = 0xFba1bc0E3d54D71Ba55da7C03c7f63D4641921B1;
    address public immutable POOL;

constructor(address pool) {
    POOL = pool;
}

    struct CollectOutput {
        uint256 tradeVolume;
    }

    constructor() {}

    function collect() external view override returns (bytes memory) {
        uint256 volume = IERC20(TOKEN).balanceOf(POOL);
        return abi.encode(CollectOutput({tradeVolume: volume}));
    }

    function shouldRespond(bytes[] calldata data)
    external
    pure
    override
    returns (bool, bytes memory)
{
    // 🔐 Planner-safety guard — MUST be first
    if (
        data.length < 2 ||
        data[0].length == 0 ||
        data[data.length - 1].length == 0
    ) {
        return (false, "");
    }

    CollectOutput memory current = abi.decode(data[0], (CollectOutput));
    CollectOutput memory past =
        abi.decode(data[data.length - 1], (CollectOutput));

    if (past.tradeVolume == 0) {
        return (false, "");
    }

    uint256 change = current.tradeVolume > past.tradeVolume
        ? current.tradeVolume - past.tradeVolume
        : past.tradeVolume - current.tradeVolume;

    // 🔁 ABI FIX: return encoded uint256 (not empty bytes)
    if (change > 1e18) {
        return (true, abi.encode(change));
    }

    return (false, "");
}

}
