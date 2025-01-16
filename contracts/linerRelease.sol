// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
    In financial field, some companies will give token to their employees.
    But there are some issues in it whitch is employees may chose to sell all of  their tokens.
    That will drop the price of the token.
What is liner release?
    Liner release means tokens will be released slowly.
    project owner will make rule about the vesting.
What rules?
    - the project owner stipulates the start time, durations and beneficiary of release.
    - the project owner transfers the locked ERC20 tokens to the TokenVesting contract.
    - beneficiary can call the release() function to gain their tokens.
 **/
contract TokenVasting{
    // event
    event ERC20Released(address indexed token, uint256 amount);

    mapping(address => uint256) public erc20Released; // token address => released amount
    address public immutable beneficiary; // beneficiary address
    uint256 public immutable start; // start timestamp
    uint256 public immutable duration; // duration

    /**
        initialize the address of beneficiary, duration, and start timestamp
    **/
    constructor(
        address beneficiaryAddress,
        uint256 durationSeconds
    ){
        require(beneficiary != address(0),"VestingWallet: beneficiary is 0 address");
        beneficiary = beneficiaryAddress;
        start = block.timestamp;
        duration = durationSeconds;
    }

    /**
        Beneficiary call this function to gain their token
    **/
    function release(address token) public {
        // call vestedAmount() to calculate the amount of token
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        // update the amount of token
        erc20Released[token] += releasable;
        // transer to beneficiary
        emit ERC20Released(token, releasable  );
        IERC20(token).transfer(beneficiary, releasable );
    }

    /**
        calculate the amount of token using the liner release algorithm
    **/
    function vestedAmount(address token, uint256 timestamp) public view returns(uint256){
        // the amount of received token of this contract (nowAmount + alreadyReleased)
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        // calculate the released amount of token using liner release algorithm
        if(timestamp < start){
            return 0;
        }else if (timestamp > start + duration){
            return totalAllocation;
        } else {
            // core algorithm
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }

}