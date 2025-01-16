// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC1155.sol";


/**
    ERC1155
    multiple Types fo token protocal
**/

/**
    In ERC1155, every token has it's own tokenId
    And, every token has it's own uri to storage it's metadata.

**/
// add uri() to query the metadata
interface IERC1155MetadataURI is IERC1155 {

    // return id token uri
    function uri(uint256 id) external view returns (string memory);

}