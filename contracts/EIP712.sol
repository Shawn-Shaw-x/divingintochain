// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


/**
/**
    EIP712 type data is an advanced signature function.
Why needs EIP712?
    EIP191 is a personal sign, but it is very simple. When the data is more complex, users only can see some hex string.
    So, it is very inconvenience for user.
    EI712 add more data to show in fronted for user to see.

How to verify signature?
    1. Sign off the chain: 
    1-1 Create domain:
     const domain = {
            name: "EIP712Storage",
            version: "1",
            chainId: "1",
            verifyingContract: "0xf8e81D47203A594245E36C48e151709F0C19fBe8",
            };
    1-2 Create types,as same as the contract
     const types = {
            Storage: [
                { name: "spender", type: "address" },
                { name: "number", type: "uint256" },
            ],
        };
        ]
    1-3 Create message, this message to be signed！
     const message = {
            spender: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
            number: "100",
        };
    1-4 Using the wallt's signTypedData() function to sign!

    2. Verify and change number on the chain, you can see it in below codes.
        Using signature to 

        Core: singer == contract owner！


**/



contract EIP712Storage {
    using ECDSA for bytes32;

    // constant
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    // constant
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");
    bytes32 private DOMAIN_SEPARATOR; // init in constructor
    uint256 number; // changed after the signature is verified
    address owner; // owner of theis contract

    constructor(){
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH, // type hash
            keccak256(bytes("EIP712Storage")), // name
            keccak256(bytes("1")), // version
            block.chainid, // chain id
            address(this) // contract address
        ));
        owner = msg.sender;
    }

    /**
     * @dev Store value in variable
     */
    function permitStore(uint256 _num, bytes memory _signature) public {
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

        // 获取签名消息hash。digest：消息摘要
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(STORAGE_TYPEHASH, msg.sender, _num))
        )); 
        
        address signer = digest.recover(v, r, s); // 恢复签名者(address而不是公钥，因为地址是公钥的派生)
        require(signer == owner, "EIP712Storage: Invalid signature"); // 检查签名

        // 修改状态变量
        number = _num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }    
}

