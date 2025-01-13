// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "./IERC721/ERC721.sol";

/**
Merkle-tree(hash tree) is a tree that built from buttom to top.
    - every leaf node is the data's hash.
    - every  non-leaf node is the two son's nodes hash; 

                            top hash( hash0 + hash1 )
                         /                       \
                hash0(hash0-0 + hash0-1)        hash1(hash1-0 + hash1-1)
                        /               \              /            \
                hash0-0(hashL1)    hash0-1(hashL2)  hash1-0(hashL3) hash1-1(hashL4)
                    |                   |               |               |
                    L1                  L2              L3              L4

What can merkle-tree do?
    - merkle tree can do the validation an security check on big data structure which called Merkle Proof.
How does it work?
    - as we see below:
        In some big data structure system, we aleardy known the top hash.
        And if we need to validate the data of L1, we need to know the ceil(log2^N),also named Proof.
        In this case, hash0-1 and hash 1-0 would be the proofs.
        So, we can calculate the hash of L1 to get hash0-0, and with hash0-1,
        we can get hash 0, still with the hash 1, we finally know the top hash!
        It means the data of L1 is secure and valid!

                            top hash( hash0 + hash1 )
                         /                       \
                hash0(hash0-0 + hash0-1)       <hash1(hash1-0 + hash1-1)>
                        /               \              /            \
                hash0-0(hashL1)  <hash0-1(hashL2)>  hash1-0(hashL3) hash1-1(hashL4)
                    |                   |               |               |
                    L1                  L2              L3              L4

**/


// to varify merkle tree
library MerkleProof {


    /**
        given the proof and leaf, we built the whole merkle tree,
        if the new tree's proof == given proof, we believe the datas is valid.
    **/
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    )internal pure returns(bool){
        return processProof(proof, leaf) == root;
    }

    /**
        We use the leaf and proof to calculate the root,
        if the new root == old root, the datas would be valid.
        - the leafs would be sorted.

    **/
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns(bytes32){
        bytes32 computedHash = leaf;
        for(uint256 i=0; i < proof.length; i++){
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    // sorted pair hash
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32){
        return a < b? keccak256(abi.encodePacked(a,b)) : keccak256(abi.encodePacked(b, a));
    }

}  

/**
Using Merkle tree to send white-list of NFT
    If we put the white-list datas in the blockchain, the cost of gas fee will be very large when we do some updates;
    So, We save the leaves and proofs off the chain, and we only need to save the root on the chain. that will very efficient and cheap!
**/
contract MerkleTree is ERC721{
    bytes32 immutable public root; // merkle tree root
    mapping(address => bool) public mintedAddress; // record the address aleardy mint

    // constructor, init the name/ symbol/ merkle tree root
    constructor(string memory name, string memory symbol, bytes32 merkelroot)  ERC721(name, symbol) {
        root = merkelroot;
    }

    // verify the address using Merkle Tree and mint
    // remember the account address is already saved off the chain! 
    // So, we need to mint in the contract about wheather the address is in the white-list
    function mint(address account, uint256 tokenId, bytes32[] calldata proof) external {
        require(_verify(_leaf(account), proof),"Invalid merkle proof"); // verify the merkle tree
        require(!mintedAddress[account],"Already minted"); // havn't minted
        _mint(account, tokenId); // mint
        mintedAddress[account] = true; // record the address already minted;
    }

    // calculate the hash of leaf node
    function _leaf(address account) internal pure returns(bytes32){
        return keccak256(abi.encodePacked(account));
    }

    // verify the data using Merkle tree
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns(bool){
        return MerkleProof.verify(proof, root, leaf);
    }
}