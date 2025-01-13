
/**
ERC7221

BTC and eth is fungible token,
but ERC721 is Non Fungible Token.
1. EIP include ERC
2. EIP is some improvements in Ethereum.
**/

/**
ERC 165 standard
ERC165 only declare a  supportInterface() function, input interfaceId id, and return true or false;
**/

interface  IERC165{
    // If implement query interfaceId, return true
    function supportsInterface(bytes4 interfaceId) external view returns(bool);
}

/**
ERC721 standard interface
**/
interface IERC721 is IERC165 {
    // emit when transfering
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // emit when approving
    event Approval(address indexed owner, address indexed aproved, uint256 indexed tokenId);
    // emit when approvalForAll (batch)
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // return the balance of NFT
    function balanceOf(address owner) external view returns(uint256 balance);
    // return the address of token owner
    function ownerOf(uint256 tokenId) external view returns(address owner);

    // safe transfer (require ERC721Receiver if reveiver is the contract)
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    // 
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approval(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns(address operator);

    function isApprovedForAll(address owner, address operator) external view returns(bool);
}

/**
!!! the NFT will into black hole if the function is not completed in the contract.

ERC721 receiver interface, contract need to implement this interface to receive token safely.(revert)
**/
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
  
}


/**
IERC721 not done, to be continue....
**/
