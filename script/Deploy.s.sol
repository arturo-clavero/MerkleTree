// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {MyToken} from "../src/MyToken.sol";
import {GenerateInput} from "./GenerateInput.s.sol";

contract Deploy is Script {
    MyToken token;
    MerkleAirdrop airdrop;
    address admin = vm.addr(3);

    function run() public {
        vm.startBroadcast(admin);
        token = new MyToken();
        airdrop = new MerkleAirdrop(address(token), admin);
        token._grantRole(token.MINTER(), address(airdrop));
        // token.mint(address(airdrop), 2500 * 1e18 * 5);
        vm.stopBroadcast();
        updateMerkle();
    }

    function updateMerkle() public {
        GenerateInput merkle = new GenerateInput();
        merkle.run();
        string memory json = vm.readFile("script/target/output.json");
        string memory rootStr = vm.parseJsonString(json, "[0].root");
        bytes32 root = vm.parseBytes32(rootStr);
        console.logBytes32(root);
        vm.startBroadcast(admin);
        airdrop.setMerkleRoot(root);
        vm.stopBroadcast();
    }
}
