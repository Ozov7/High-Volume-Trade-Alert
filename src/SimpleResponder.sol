// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleResponder {
    function respondCallback(bytes calldata data) external {
    uint256 volume = abi.decode(data, (uint256));
}
}
