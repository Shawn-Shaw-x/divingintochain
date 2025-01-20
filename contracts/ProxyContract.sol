// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is proxy contract?
    We seperate the logic from the state bariable and put them into two different contract.
What is the advantages of proxy contract?
    1. Upgrateable: all we need to do is pointting the new logic contract 
    2. Gas saving: if we have the same logic in differnt contracts, 
        we can deploy one logic contract and use the proxy contract to point it

        delegateCall:
    -----             -----------                     -----------
   |userA| --call--> | contractB |  --delegateCall-->| contractC |
    -----             -----------                     -----------
                      contex: B                         contex: B
                      msg.sender: A                     msg.sender: A
                      msg.value: A                      msg.value: A
**/

contract Proxy{
    address public implementation; // logic contract address.this variable needs to be as same as the logic contract.
    // here no variable 'x', but logic contract has it. so here's will be 0


    constructor(address implementation_){
        implementation = implementation_;
    }

    /**
        Using the inline assembly to make this function implement a feature 
            that means calling this function is calling this contract is calling the logic contract

        Using assembly make fallback function can return
    **/

     fallback() external payable  {
        address _implementation = implementation;
        assembly{
        // copy msg.data to memory
        // params: init location,calldata location,calldata length
        calldatacopy(0, 0, calldatasize())

        // using delegatecall call implementation contract
        // params: gas, target contract address, input mem init location, 
        //        input mem length, output area mem init length,
        let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

        // copy the return data to memory
        // params: memory init location, returndata init location, returndata length
        returndatacopy(0,0, returndatasize())

        switch result
        // if delegate call fail, revert
        case 0 {
            revert(0, returndatasize())
        }
        default {
            return(0,returndatasize())
        }

        }
    }
}

// logic contract: to be call
contract Logic{
    address public implementation; // as same as Proxy to avoid the slot conflict
    uint public x = 99;
    event CallSuccess(); // success event

    // selector: 0xd09de08a
    function increment() external returns(uint){
        emit CallSuccess();
        return x + 1;
    }

}

contract Caller {
    address public proxy; // proxy contract address
    
    constructor(address proxy_){
        proxy = proxy_;
    }
    // using proxy to call increment() function
    function increment() external returns(uint){
        (,bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));

        // decode the return, so using this increment will return
        return abi.decode(data, (uint));
    }
}