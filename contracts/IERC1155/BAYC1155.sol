// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC1155.sol";


/**
    implement a BAYC 
**/
contract BAYC1155 is ERC1155 {
    uint256 constant MAX_ID = 10000;
    // constructor
    constructor() ERC1155("BAYC1155", "BAYC1155"){

    }

    // the baseURI of BAYC is ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/
    function _baseURI() internal  pure override returns (string memory){
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    // mint
    // NOTE: if amount == 1, token would be unfungible token
    //          amount != 1, token would be fungible token
    function mint(address to, uint256 id, uint256 amount) external {
        // id would be less than 10,000
        require(id < MAX_ID, "id oerflow");
        _mint(to, id, amount, "");
    }

    // batch mint function
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) external {
        // id would be less than 10,000
        for(uint256 i = 0; i < ids.length; i++){
            require(ids[i] < MAX_ID, "id overflow");
        }
        _mintBatch(to, ids, amounts,"");
    }
}