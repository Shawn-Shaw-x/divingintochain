// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


import "https://github.com/AmazingAng/WTF-Solidity/blob/main/34_ERC721/ERC721.sol";

contract OnchainRandomNum{
    /**
        false random num generator
        using keccak256 pack some variable
        cast to uint 
    **/
    function getRandomOnchain() public view returns(uint256){
        bytes32 randomBytes = keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number-1)));
        return uint256(randomBytes);
    }

    /**
    Off-chain random number
    We usually use ChainLink VRF(Vertified Random Function) to create random number off the chain.
    Work flow:

    contract request randomness  -->  ChainLink VRF generate randomness and send proof  ---> VRF verifies the randomness  --> contract verified randomness

    TBD...(I don't have enougth ETH to pay the gas to connect ChainLink T_T)
    **/
}

/**
    Using Onchain Randomness to generate tokenId
**/
contract NFTByOnchainRandomness is ERC721{
    uint256 public totalSupply = 100;
    uint256[100] public ids; // calculate the tokenId to be minted
    uint256 public mintCount; // count of tokenId

    constructor() ERC721("WTF Random ","WTF"){}

        /**
        false random num generator (unsafe)
        using keccak256 pack some variable
        cast to uint 
    **/
    function getRandomOnchain() public view returns(uint256){
        // it has some security problem when we are generating randomness on the chain.
        bytes32 randomBytes = keccak256(abi.encodePacked(block.timestamp, msg.sender, blockhash(block.number-1)));
        return uint256(randomBytes);
    }


   /** TBD 有点难这个算法。。。
    * 输入uint256数字，返回一个可以mint的tokenId
    * 算法过程可理解为：totalSupply个空杯子（0初始化的ids）排成一排，每个杯子旁边放一个球，编号为[0, totalSupply - 1]。
    每次从场上随机拿走一个球（球可能在杯子旁边，这是初始状态；也可能是在杯子里，说明杯子旁边的球已经被拿走过，则此时新的球从末尾被放到了杯子里）
    再把末尾的一个球（依然是可能在杯子里也可能在杯子旁边）放进被拿走的球的杯子里，循环totalSupply次。相比传统的随机排列，省去了初始化ids[]的gas。
    */
    function pickRandomUniqueId(uint256 random) private returns (uint256 tokenId) {
        //先计算减法，再计算++, 关注(a++，++a)区别
        uint256 len = totalSupply - mintCount++; // 可mint数量
        require(len > 0, "mint close"); // 所有tokenId被mint完了
        uint256 randomIndex = random % len; // 获取链上随机数

        //随机数取模，得到tokenId，作为数组下标，同时记录value为len-1，如果取模得到的值已存在，则tokenId取该数组下标的value
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex; // 获取tokenId
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1]; // 更新ids 列表
        ids[len - 1] = 0; // 删除最后一个元素，能返还gas
    }

    // using false randdomness to mint
    function mintRandomOnchain() public {
        uint256 _tokenId = pickRandomUniqueId(getRandomOnchain());// using randomness on chain to generate tokenId
        _mint(msg.sender, _tokenId);
    }

    

}