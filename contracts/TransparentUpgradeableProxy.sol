// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is disavantages of simple upgradeable contract?
    In solidity, selector is the first 4 bytes of hash.
    bytes4(keccak("mint(address)"))
    So, it is very easy to meet conflict.
    In simple upgradeable contract, proxy contract is different form logic contract.
    So, image that there is a function called "a()"  in logic contract.
    But there is a function called "upgrade()" in proxy contract.
    And if "a()" has the selector as same as the "upgrade()";
    When the admin call "a()", the "upgrade()" will be called,
    In that case, logic proxy will be upgraded to a blackhole contract, it is very dangrous!

How to fix the disavantages in simple upgradeable contract?
    answer: use the transparent upgrate contract

What is the transparent upgrate contract?
    It is very simple: making all the function in logic can not be called by admin.

What is the cost?
    More gas consume! Because the “require(msg.sender != admin);” in fallback()
**/

// demo contract, can not be used in production
contract TransparentUpgradeableProxy{
    address implementation;// logc contract address
    address admin; // admin
    string public words; // string , can be changed by logic contract's function

    constructor(address _implementation){
        admin = msg.sender;
        implementation = _implementation;
    }
    // fallback delegate to logic contract
    // can not be called by admin in case of the selector conflict
    fallback() external payable {
        require(msg.sender != admin);
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
     }

     // upgrate function, change the address of contract, only can be called by admin
     function upgrate(address newImplementation) external {
        if(msg.sender != admin) revert();
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