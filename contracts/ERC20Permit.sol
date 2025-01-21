// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is ERC20permit?
    In ERC20, we need to approve a transaction then we can execute a transaction, 
        both of them is on chain.
    But in ERC20permit, all you need to is execute a transaction. 
        the approval process is out of the chain.(become the sign process)

How to implement this goal?
    1. approve proceess become the process of signature.
    2. when approved, user can send this signature to third part,
         and  delegate the third part to execute this transaction.


        Such as:

          user                                      user 
        /      \                                   /    \
   approve(TX)  swap(TX)                        sign    swap(TX)
    /            \                              /            \
 ERC20 --------> Uniswap                 ERC20Permit ------> Uniswap 
   |               |                           |               |                    
    <-transferForm--                            <--Permit-------

**/

import "./IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
    ERC20 Permit allows transaction be approved by using signature！
    So. token holder doesn't need to approve token  and doesn't need ETH for the gas of  approve()
**/
contract ERC20Permit is ERC20, IERC20Permit, EIP712{
    mapping (address => uint ) private  _nonces;

    bytes32 private constant _PERMIT_TYPEHASH =
             keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name, string memory symbol) EIP712(name,"1") ERC20(name, symbol){}
    

    // permit: varify the signature and send approve
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        // check deadline
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline.");
        // construct hash
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner)));
        bytes32 hash = _hashTypedDataV4(structHash);

        // get the signer and varify the signature
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        // approve
        _approve(owner, spender, value);
    }

    // nonces
    function nonces(address owner) public view virtual override returns(uint256){
        return _nonces[owner];
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "消费nonce": 返回 `owner` 当前的 `nonce`，并增加 1。
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        current = _nonces[owner];
        _nonces[owner] += 1;
    }
}