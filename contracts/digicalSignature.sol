// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

    import "https://github.com/AmazingAng/WTF-Solidity/blob/main/34_ERC721/ERC721.sol";

/**
    the signature of Ethereum using is is ECDSA which has 3 main feature
    1. identity authorization: prove the signature side is the owner of the private key
    2. can not deny: sender can not deny the message he send.
    3. intergrety: with the verify of the signature of sending, we can know whether the message has beend changed.

What's include?
    1. private key: own by signature owner.
    2. public key: own by everyone want to verify the messge.

**/
contract DigitalSignature{
    /**
       1. Packing message
    **/
    function getMessageHash(address _account, uint256 _tokenId) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_account, _tokenId));
    }
    /**
        2. Calculate the message of the signature of Ethereum
            - Using this function, no one can sign the malicous transaction by mistake
            because of the message will no longer be the transaction to be excuted.
    **/
    function toEthSignatureMessageHash(bytes32 hash) public pure returns(bytes32){
        // the length of hash is 32
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

/**
How to verify signature?
    - To verify the signature, verifier need to hold the message/signature/public key. 
**/
    // the first step is recovering the public key using message and signature.
      // @dev 从_msgHash和签名_signature中恢复signer地址
    function recoverSigner(bytes32  _msgHash, bytes memory _signature) internal pure returns(address){
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }
    // the second step is verifing the signature using public key.
    /// @param _signer public key
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) internal pure returns (bool){
        return recoverSigner(_msgHash, _signature) == _signer;
    }
}

/**
Release white-list using signature
    We can use the signature to release the white-list without costing any gas fee.
    This way of releasing white-list is more cheaper than Merkle Tree.
    1. Sending the signature of address + tokenId to user. ( off-the blockchain)
    2. verifing the signature using ECDSA when minting (on the blockchain)

How it to signature?
    1. Normal message: keccak256(abi.encodePacked(_account, _tokenId)), and then we get the normal message!
    2. Ethereum message: keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32"), hash), and then get get the Ethereum message!
    3. Using prive key and Ethereum message to calculate the signature!

    Then we will know the message and the signature!

How to verify the message and signature?
    1. Recover the public key: recover the public key using ECDSA library.
    2.Ccompare the contract public key == recovered public key.

    If equal, it means the message and signature are both valid.
**/
contract SignatureNFT is ERC721 {
    address immutable public signer; // public key address 
    mapping(address => bool) public mintedAddress; // record the address already minted

    // constructor, init the name /symbol/ sign address
    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol){
        signer = _signer;
    }

    // verify signature and mint using ECDSA
    function mint(address _account, uint256 _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId); // packing _account and _tokenId
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash);// calculate the message of Ethereum
        require( verify(_ethSignedMessageHash, _signature) ,"invalid signature");
        require(!mintedAddress[_account],"already minted");
        _mint(_account, _tokenId);// mint
        mintedAddress[_account] = true; // record the adddress already minted.
    }

    /*
     * 将mint地址（address类型）和tokenId（uint256类型）拼成消息msgHash
     * _account: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
     * _tokenId: 0
     * 对应的消息: 0x1bf2c0ce4546651a1a2feb457b39d891a6b83931cc2454434f39961345ac378c
     */
    function getMessageHash(address _account, uint256 _tokenId) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    // ECDSA验证，调用ECDSA库的verify()函数
    function verify(bytes32 _msgHash, bytes memory _signature)
    public view returns (bool)
    {
        // signer: public key of this contract
        return ECDSA.verify(_msgHash, _signature, signer);
    }


}

library ECDSA{
    /**
     * @dev 通过ECDSA，验证签名地址是否正确，如果正确则返回true
     * _msgHash为消息的hash
     * _signature为签名
     * _signer为签名地址
     */
    function verify(bytes32 _msgHash, bytes memory _signature, address _signer) internal pure returns (bool) {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    // @dev 从_msgHash和签名_signature中恢复signer地址
    function recoverSigner(bytes32 _msgHash, bytes memory _signature) internal pure returns (address){
        // 检查签名长度，65是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        // 目前只能用assembly (内联汇编)来从签名中获得r,s,v的值
        assembly {
            /*
            前32 bytes存储签名的长度 (动态数组存储规则)
            add(sig, 32) = sig的指针 + 32
            等效为略过signature的前32 bytes
            mload(p) 载入从内存地址p起始的接下来32 bytes数据
            */
            // 读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            // 读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            // 读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        // 使用ecrecover(全局函数)：利用 msgHash 和 r,s,v 恢复 signer 地址
        return ecrecover(_msgHash, v, r, s);
    }
    
    /**
     * @dev 返回 以太坊签名消息
     * `hash`：消息哈希 
     * 遵从以太坊签名标准：https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * 以及`EIP191`:https://eips.ethereum.org/EIPS/eip-191`
     * 添加"\x19Ethereum Signed Message:\n32"字段，防止签名的是可执行交易。
     */
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}