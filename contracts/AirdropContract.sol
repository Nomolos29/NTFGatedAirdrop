// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Airdrop {
    IERC20 public token;
    IERC721 public gatePass;

    bytes32 public merkleRoot;

    mapping(address => bool) public hasClaimed;

    error airdropAlreadyClaimed();
    error notAValidClaimer();

    event ValidUser(address indexed user);
    event AirdropClaimed(address indexed claimant, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot,address _gatePass) {
      token = IERC20(_token);
      gatePass = IERC721(_gatePass);
      merkleRoot = _merkleRoot;
    }

    function claimAirdrop(
        uint256 amount,
        uint _nftTokenId,
        bytes32[] calldata merkleProof
    ) external {
        address isOwner = gatePass.ownerOf(uint _nftTokenId);
        
        if(isOwner != msg.sender) { revert notAValidClaimer(); }
        if(hasClaimed[msg.sender]) { revert airdropAlreadyClaimed(); }
  
        // bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));

        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "Invalid Merkle proof."
        );

        hasClaimed[msg.sender] = true;

        require(token.transfer(msg.sender, amount), "Token transfer failed.");

        emit AirdropClaimed(msg.sender, amount);
    }
}
