// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyToken is ERC20, AccessControl {
    
    bytes32 constant public MINTER = keccak256("MINTER_ROLE");

    constructor(address admin) ERC20("My token", "MT") {
        if (admin == address(0)) admin = msg.sender;
        _grantRole("DEFAULT_ADMIN_ROLE", admin);

    }

    function mint(address account, uint256 value) external onlyRole(MINTER) {
        _mint(account, value);
    }
}
