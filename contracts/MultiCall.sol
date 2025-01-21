// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is multi call ?
    Multi call can be used to execute more than one function calling in one transaction.
What is the advantages of multi call?
    1. Convenience: all function calls can be used in one transaction.
    2. Gas saving:  save gas fee.
    3. Atomic: all done or all fail.
**/

contract MultiCall{
    // call struct: 
    // contain target contract address, 
    // allowFailure 
    // callData
    struct Call{
        address target;
        bool allowFailure;
        bytes callData;
    } 

    // struct of result
    struct Result{
        bool success;
        bytes returnData;
    }

    function multicall(Call[] calldata calls) public returns(Result[] memory returnData){
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata calli;

        //call in a loop
        for(uint256 i = 0; i< length; i++){
            Result memory result = returnData[i];
            calli = calls[i];
            (result.success, result.returnData) = calli.target.call(calli.callData);
            // if calli.allowFailure and result.success both are false, revert
            if(!(calli.allowFailure || result.success)){
                revert("Multicall: call failed");
            }
        }
    }
}


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MCERC20 is ERC20{
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){}

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }
}

// 0x40c10f190000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000032
// 0x40c10f19000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb20000000000000000000000000000000000000000000000000000000000000064
// [["0x16500370A61d015f025e4C74dAdb972042567d9a",false,"0x40c10f190000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000032"],["0x16500370A61d015f025e4C74dAdb972042567d9a",false,"0x40c10f19000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb20000000000000000000000000000000000000000000000000000000000000064"]]