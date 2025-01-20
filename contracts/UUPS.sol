// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is UUPS
    UUPS is universal upgradeable proxy standard
What is different between UUPS and normal upgrade proxy
    standard        upgrade function location       is selector conflict?       disavantage

    upgradeable         proxy                               yes                 selector conflict
    transparent         proxy                               no                  too much gas
    UUPS                logic                               no                  more complex

How to write a UUPS
    We put the upgrade function on logic contract because of the logic function have the contex of proxy.
    So the changed of state variable on logic contract means the changed of the state variable of proxy contract;

        delegateCall:
    -----             -----------                     -----------
   |userA| --call--> | contractB |  --delegateCall-->| contractC |
    -----             -----------                     -----------
                      contex: B                         contex: B
                      msg.sender: A                     msg.sender: A
                      msg.value: A                      msg.value: A
    
Note:
    We have to make sure we offer a right logic address to upgrate
    Or else we will no be able to upgrade anymore.
**/


contract UUPSProxy{
    address public implementation;// logic contract address
    address public admin; // admin address
    string public words; // string, can be changed by contract's function

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }

    // delegate to logic contract
    fallback() external payable { 
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
}

contract UUPSLogicOld{
    address public implementation; // logic contract addressw
    address public admin; // admin
    string public words; // words, can be changed by contract's function
    // selector: 0xc2985578
    function foo()public {
        words = "old";
    }

    // upgrade funciton, change the contract to new logic address
    // must be called by admin
    // selector: 0x0900f010
    // in UUPS, logic contract must include upgrade function , or else it will not be upgradeable
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}


contract UUPSLogicNew{
    address public implementation; // logic contract addressw
    address public admin; // admin
    string public words; // words, can be changed by contract's function
    // selector: 0xc2985578
    function foo()public {
        words = "new";
    }

    // upgrade funciton, change the contract to new logic address
    // must be called by admin
    // selector: 0x0900f010
    // in UUPS, logic contract must include upgrade function , or else it will not be upgradeable
    function upgrade(address newImplementation) external {
        require(msg.sender == admin);
        implementation = newImplementation;
    }
}