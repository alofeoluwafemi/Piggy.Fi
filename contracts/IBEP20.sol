// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function allowance(address owner, address spender)
        external
        returns (uint256);
}
