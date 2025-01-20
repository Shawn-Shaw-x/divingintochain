// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is upgratable contract?
    We change the implementation to another contract on proxy contract
**/

contract SimpleUpgrate{
    address public  implementation; // logic contract address
    address public admin; // admin address
    string public words; // string, that can be changed by logic contract.

    // init the admin and logic contract's address
    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    // fallback, delegate to logic contract
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // upgrate function, change the address of logic contract, only can be called by admin
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}

contract OldLogic{
    // state variable must be as same as the proxy contract in case of slot conflict
    address public implementation; 
    address public admin;
    string public words; // string, can be changed by logic function

    // selector: 0xc2985578
    function foo() public {
        words = "OLD";
    }
}

contract NewLogic{
    // state variable must be as same as the proxy contract in case of slot conflict
    address public implementation; 
    address public admin;
    string public words; // string, can be changed by logic function

    // selector: 0xc2985578
    function foo() public {
        words = "NEW";
    }
}