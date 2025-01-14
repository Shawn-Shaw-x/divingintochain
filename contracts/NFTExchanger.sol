// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "./IERC721/IERC721Receiver.sol";
import "./IERC721/IERC721.sol";
import "./IERC721/WTFApe.sol";

/**
NFT exchanger implementation
    1. Buyer: purchase()
    2. Seller: list()/ revoke()/ update()
    3. Order: one tokenId == one order. An order includes price and owner. it will be null when the order purchase() or revoke().

**/

contract NFTExchanger is IERC721Receiver{

    // list nft
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    // purchase
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    // revoke
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);    
    // update price
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);

    // define order
    struct Order{
        address owner;
        uint256 price;
    }
    // NFT Order mapping
    mapping(address => mapping(uint256 => Order)) public nftList;

    // to receive ETH
    fallback() external payable { } 

    // impletement{IERC721Receiver} onERC721Received , can receive ERC721 token
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external  override returns(bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
        Seller create NFT and create order , emit List event.
        NFT will transfer from seller to NFTExchanger contract.
    **/
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public{
        IERC721 _nft = IERC721(_nftAddr); // declare IERC721 interface contract
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval"); //get contract approval
        require(_price > 0); // need price > 0

        Order storage _order = nftList[_nftAddr][_tokenId]; // set NFT holder and price
        _order.owner = msg.sender;
        _order.price = _price;

        // transfer NFT from sender to contract 
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        // emit list event
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    /**
        Seller cancel the list, emit revoke event.
        Transfer NFT from contract to buyer
    **/
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId]; // gain Order
        require(_order.owner == msg.sender,"Not Owner"); // must be launch by owner
        // declare IERC721 interface
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT exist in contract

        // transfer NFT to seller
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // transfer fom contract to seller

        // emit revoke event
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    /**
        Update list price by seller
    **/
    function update(address _nftAddr, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price"); // NFT price> 0
        Order storage _order = nftList[_nftAddr][_tokenId]; // gain Order
        require(_order.owner == msg.sender, "Not Owner"); // must be launched by holder
        // declare IERC721 interface contract variable
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order");
        // adjust NFT price
        _order.price = _newPrice;

        // emit update event
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);

    }
    /**
        Purchase: buyer purchase NFT, emit Purchase event.
        The NFT will be transferd from contract to buyer
    **/
    function purchase(address _nftAddr, uint256 _tokenId) payable public {
        Order storage _order = nftList[_nftAddr][_tokenId]; // gain Order
        require(_order.price > 0, "Invalid Price"); // the price of NFT > 0
        require(msg.value >= _order.price, "Increase price"); // the price of buyer > order.price
        // declare IERC721 interface contract variable
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this),"Invalid Order"); //NFT exist in contract

        // transfer NFT to buyer
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // transfer ETH to seller, rest ETH to buyer
        payable (_order.owner).transfer(_order.price);
        payable (msg.sender).transfer(msg.value-_order.price);

        delete nftList[_nftAddr][_tokenId]; // delete Order

        // emit purchase event
        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }




}