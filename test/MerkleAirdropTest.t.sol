// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Deploy} from "../script/Deploy.s.sol";
import {MyToken} from "../src/MyToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract MerkleTest is Test {
    MerkleAirdrop airdrop;
    MyToken token;
    address admin;

    address[] whitelistUsers;
    uint256[] amounts;
    bytes32[] leaves;
    bytes32[][] proofs;
    uint256 count;

    function setUp() public {
        admin = msg.sender;

        // Deploy contracts
        Deploy deploy = new Deploy();
        deploy.run();
        airdrop = deploy.airdrop();
        token = deploy.token();

        string memory input = vm.readFile("script/target/input.json");
        count = uint256(vm.parseJsonUint(input, ".count"));
        whitelistUsers = new address[](count);
        amounts = new uint256[](count);
        leaves = new bytes32[](count);
        proofs = new bytes32[][](count);

        string memory output = vm.readFile("script/target/output.json");

        for (uint256 i = 0; i < count; i++) {
            whitelistUsers[i] = vm.parseJsonAddress(output, string.concat("[", vm.toString(i), "].inputs[0]"));
            amounts[i] = vm.parseJsonUint(output, string.concat("[", vm.toString(i), "].inputs[1]"));
            leaves[i] = vm.parseBytes32(vm.parseJsonString(output, string.concat("[", vm.toString(i), "].leaf")));

            proofs[i] = abi.decode(
                vm.parseJson(output, string.concat("[", vm.toString(i), "].proof")),
                (bytes32[])
            );
        }
        console.log("Loaded %s whitelist entries", count);
    }

    function testFirstUser() public {
        console.log("user0", whitelistUsers[0]);
        console.log("amount0", amounts[0]);
        console.logBytes32(leaves[0]);
        console.log("proof0 length", proofs[0].length);
    }

}
