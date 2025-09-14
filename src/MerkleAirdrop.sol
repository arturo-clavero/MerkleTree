// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IMyToken} from "./interfaces/IMyToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is Ownable {
    IMyToken private immutable i_token;
    bytes32 public merkleRoot;
    mapping(address=>bool) alreadyClaimed;


    error MerkleAirdrop__alreadyClaimed();
    error MerkleAirdrop__invalidClaimProof();
    error MerkleAirdrop__invalidInputLengths();

    constructor(address _token, address admin) Ownable(msg.sender) {
        i_token = IMyToken(_token);
        if (admin != address(0) && admin != msg.sender) {
            _transferOwnership(admin);
        }
    }

    function setMerkleRoot(bytes32 _root) external onlyOwner {
        merkleRoot = _root;
    }

    function claim(
        address account, 
        uint256 amount, 
        bytes32 leaf, 
        bytes32[] calldata proofs
    ) external {
        if (alreadyClaimed[account]) revert MerkleAirdrop__alreadyClaimed();

        if (!MerkleProof.verifyCalldata(proofs, merkleRoot, leaf)) revert MerkleAirdrop__invalidClaimProof();
        alreadyClaimed[account] = true;

        i_token.mint(account, amount);
    }

    function batchClaim(
        address[] calldata accounts,
        uint256[] calldata amounts,
        bytes32[] calldata leaves,
        bytes32[] calldata proofs,
        bool[] calldata proofFlags
    ) external {
        
        uint256 len = accounts.length;
        if (len != amounts.length || len != leaves.length)
            revert MerkleAirdrop__invalidInputLengths();
        
        for(uint256 i = 0; i < accounts.length; i ++) {
            if (alreadyClaimed[accounts[i]]) revert MerkleAirdrop__alreadyClaimed();
            alreadyClaimed[accounts[i]] = true;
        }

        if (!MerkleProof.multiProofVerifyCalldata(proofs, merkleRoot, leaves)) revert MerkleAirdrop__invalidClaimProof();

        for(uint256 i = 0; i < accounts.length; i ++) {
            if (alreadyClaimed[accounts[i]]) continue;
            alreadyClaimed[accounts[i]] = true;
            i_token.mint(accounts[i], amounts[i]);
        }
    }
}
