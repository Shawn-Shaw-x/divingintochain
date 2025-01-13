// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

    import "@openzeppelin/contracts/access/Ownable.sol";
    import "https://github.com/AmazingAng/WTF-Solidity/blob/main/34_ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721{
    /**
    Dutch Auction is a special way of auction that means 
    the price of the product will decrease until some buy it.

    features:
        1. it can let the project owner gaining the most profit of the auction
         because of the price is droping slowly.
        2. the process of this kind of auction will last long time which the gas war can be avoided.
    **/
    uint256 public constant COLLECTION_SIZE = 10000; // total amount of NFT
    uint public constant AUCTION_START_PRICE = 1 ether; // start price
    uint public constant AUCTION_END_PRICE = 0.01 ether; // end price
    uint public constant AUCTION_TIME = 10  minutes; // all dropping time
    uint public constant AUCTION_DROP_INTERVAL = 1 minutes; // drop per step
    uint public constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE - AUCTION_END_PRICE)/
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); // drop per step when price dropping

    uint256 public auctionStartTime; // timestamp when the auction started
    string private _baseTokenURL; // metadata URL
    uint256[] private _allTokens; // record all existed tokenId

    constructor() Ownable(msg.sender) ERC721("WTF Dutch Auction","WTF Dutch Auction"){
        auctionStartTime = block.timestamp;
    } 

    function setAuctionStartTime(uint32 timestamp) external onlyOwner{
        auctionStartTime = timestamp;
    }

    function getAuctionPrice() public view returns (uint256){
        if(block.timestamp < auctionStartTime){ // init price
            return AUCTION_START_PRICE;
        }else if (block.timestamp - auctionStartTime >= AUCTION_TIME){ // end price
            return AUCTION_END_PRICE;
        }else {  // every steps price;
            uint256 steps = (block.timestamp - auctionStartTime) /
            AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE -(steps * AUCTION_DROP_PER_STEP);
        }
    }

    /**
     * ERC721Enumerable中totalSupply函数的实现
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }
    // /**
    //  * Private函数，在_allTokens中添加一个新的token
    //  */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // mint some NFT using ETH
    function auctionMint(uint256 quantity ) external payable{
        uint256 _saleStartTime = uint256(auctionStartTime); // build local variable, decress the gas
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        ); // check  the initial time of auction to know if the auction began

        require(
            totalSupply() + quantity <= COLLECTION_SIZE,
            "not enougth remaining reserved for aucton to support desired mint amount"
        ); // check the maximum limit fo NFT

        uint256 totalCost = getAuctionPrice() * quantity; // calculate the cost of mint
        require(msg.value >= totalCost, "need to send more ETH"); // check the balance of msg enougth?
        // mint NFT
        for(uint256 i=0; i < quantity; i++){
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }
    }
    // withdraw money 
    function withdrawMoney() external onlyOwner{
        (bool success,) = msg.sender.call{value: address(this).balance}("");// call function  
        require(success,"Transfer failed.");
    }


    


}