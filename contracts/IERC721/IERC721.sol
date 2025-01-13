// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev ERC721标准接口.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // emited when batch approval
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // return the NFT balance of some address owner
    function balanceOf(address owner) external view returns (uint256 balance);

    // return the owner of tokenId
    function ownerOf(uint256 tokenId) external view returns (address owner);

    // normal transfer function overload
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    // safe transfer
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    // narmal transferFrom
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    // approve
    function approve(address to, uint256 tokenId) external;

    // approve all NFT for an address
    function setApprovalForAll(address operator, bool _approved) external;

    // return the adderess of this NFT
    function getApproved(uint256 tokenId) external view returns (address operator);

    // query the NFT of this address approved for another operator
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}