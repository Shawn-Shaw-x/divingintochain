// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is cross chain bridge?
    Cross chain bridge is a protocal of block chain. 
    It make the transfering data between two or above block chain is avaliable.
    Such as a ERC20 token in Ethereum main net can be transfered to another side chain or independent chain
How many types in cross chain bridge?
    1. Burn/Mint:
        - Burn some token on origin chain and mint equal amount token in target chain.
        - Need burn/mint right in both chain. 
        - Abaliable for project owner.
    2. Stake/Mint:
        - Stake some tokens on origin chain and mint equal amount tokens on target chain.
        - Don't need any right to do it.
        - Common resolution for cross chain bridge
        - It contains some risk in this resolution. 
            the asset on target chain will lost when origin chain  being attacked.
    3. Stake/Unstake:
        - Stake some tokens on origin chain and unstake equal amount tokens on target chain.
        - Need stake/unstake right on both chain.
        - Resolution for inspiring user to staking on both chain.
**/


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
Why burn() and mint() functions need to be separated?
    If burn() and mint() was puted in the bridge() function, some security problem will occure
    
    1. Token lost: if user burn token successfully in origin chain but fail to mint token on target chain
    2. Lack of authorization(double-spending attack): if some problem accured in _burn()（not done） 
            But mint() still continue, it may occur double-spending attack

**/
contract CrossChainBridge is ERC20, Ownable{
    // Bridge event
    event Bridge(address indexed user, uint256 amount);
    // Mint event
    event Mint(address indexed to, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256  totalSupply
    ) payable ERC20(name, symbol) Ownable(msg.sender){
        _mint(msg.sender, totalSupply);
    }

    // burn amount of token on the current chain and mint on the other chain.
    // don't need to mint token in this function because Ether.js will listen the Bridge event
    //  and call the mint() function.
    function bridge(uint256 amount) public {
        _burn(msg.sender, amount);
        emit Bridge(msg.sender, amount);
    }
    
    // when project owner has listened the Bridge event it would call this function to mint token
    function mint(address to, uint amount) external onlyOwner{
        _mint(to, amount);
        emit Mint(to, amount);
    }
}