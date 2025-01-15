// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/**
What is WETH?
    ETH is the original token of Ethereum, but it is not designed for ERC20 standard.
    So, WETH is designed for ERC20 which can be used to intereact with DApps.

How to build WETH
    except for the ERC standard, we need 2 more features below:
    1. deposit: wrap ETH to WETH, gain equal amount WETH.
    2. withdraw: unwrap WETH, gain equal ETH
**/

contract WETH is ERC20{
    // event deposit and withdraw
    event Deposit(address indexed dst, uint wad);
    event Withdraw(address indexed src, uint wad);

    constructor() ERC20("WETH","WETH"){

    }
    // callback function 
    // deposit() will be triggered when users send ETH to this contract
    fallback()  external payable {
        deposit();
    }

    // callback function 
    // deposit() will be triggered when users send ETH to this contract
    receive() external payable {
        deposit();
    }

    // deposit function,
    // mint equal amount WETH when users send ETH to this contract.
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

}

