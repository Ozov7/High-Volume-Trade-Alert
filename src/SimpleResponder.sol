// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleResponder {
    event HighVolumeDetected(uint256 volume);

    function respondCallback(uint256 volume) external {
        emit HighVolumeDetected(volume);
        // Add mitigation logic here (pause, alert, etc.)
    }
}
