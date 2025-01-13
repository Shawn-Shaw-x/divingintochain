// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract calWX{
    function cal() external returns(bytes32){
        return keccak256("cola_ocean");
    } 
}