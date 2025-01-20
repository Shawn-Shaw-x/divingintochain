pragma solidity ^0.8.21;

/**
What is multiple signature wallet?
    Transaction must be signatured by multiple private key holder.
    In a wallet, there are 3 people hold the private key of this wallet, 
        and every transaction need more than 2 people to sign it.
How to build a multiple sign wallet in solidity?
    1. Set the signatee and threadhold on the chain.
    2. Create transaction out of the chain.
        to: target contract
        value: ETH amount
        data: calldata(selector and params)
        nonce: 0(and  it will increase when the transaction is adding), 
                in case of the signature repeat attact 
        chainid: chain id, in  case of the differnet chain signature repeat attack
    3. Collect signature out out the chain.
    4. Call the multiple sign contract and execute the function on the chain.
**/


contract MultiSignWallet{
    event ExecutionSuccess(bytes32 txHash);// success event
    event ExecutionFail(bytes32 txHash); // Fail event

    address[] public owners; // multiple signature holders array
    mapping(address => bool) public isOwner; // recored If an address is multiple sign holder
    uint256 public ownerCount; // multiple signature holder count
    uint256 public threshold; // need k people to execute the transaction
    uint256 public nonce; // nonce, in case of the signature repeat attack

    receive() external payable {}

    // init owner, isOwner, ownerCount, threshold 
    constructor(
        address[] memory _owner,
        uint256 _threadhold
    ){
        _setupOwners(_owner, _threadhold);
    }

    /**
        init owners, isOwner, ownerCount, threshold
    **/
    function _setupOwners(address[] memory _owners, uint256 _threshold) internal{
        // threshold never be inited
        require(threshold == 0, "WTF5000");
        // threshold less or equal than owners' size
        require(_threshold <= _owners.length, "WTF5001");
        // threshold is more than 1
        require(_threshold >= 1, "WTF5002");

        for(uint256 i = 0; i< _owners.length; i++){
            address owner = _owners[i];
            // multiple signature holder != 0 or this contract address or repeat address
            require(owner != address(0) && owner != address(this) && !isOwner[owner],"WTF5003");
            owners.push(owner);
            isOwner[owner] == true;
        }
        ownerCount = _owners.length;
        threshold =_threshold;
    }


    // check the signature and execute the transaction using call()
    function execTransaction(
        address to, // target contract address
        uint256 value, // ETH amount
        bytes memory data, // calldata
        bytes memory singatures // multiple signature
    )public payable virtual returns(bool success){
        // encode trx data, calculate the hash
        bytes32 txHash = encodeTransactionData(to, value, data, nonce, block.chainid);
        nonce++; // add nonce
        checkSignatures(txHash, singatures);// check the signatures
        // use call() to execute the transaction, and get the return
        (success,) = to.call{value: value}(data);
        // require(success, "WTF5004”）；
        if(success) emit ExecutionSuccess(txHash);
        else emit ExecutionFail(txHash);
    }

    // check  if the signature equal to trx data, if invalid , revert
    function checkSignatures(
        bytes32  dataHash,
        bytes memory signatures
    ) public view {
        // read multiple sign threshold
        uint256 _threshold = threshold;
        require(_threshold > 0, "WTF5005");
        // check long enougth for signature
        require(signatures.length >= _threshold * 65, "WTF5006");
        // Using a loop to check the validation of collected signature
        // 1. Using ecdsa to check the validation of  signature
        // 2. Using currentOwner > lastOwner to ensure the signature is from multiple signature
        // 3. Using isOwner[currentOwner] to check the holder is in owners.
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for(i = 0; i < threshold; i++){
            (v, r, s) = signatureSplit(signatures, i);
            // using ecrecover to check the validation of signature
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)),v,r,s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "WTF5007");
            lastOwner = currentOwner;
        }
    }

    function signatureSplit(bytes memory signatures, uint256 pos) internal pure returns(
        uint8 v,
        bytes32 r,
        bytes32 s
    ){
        // format: {bytes32 r} {bytes32 s} {uint8 v}
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }


    function encodeTransactionData(
        address to, // target contract address
        uint256 value, // ETH
        bytes memory data, // calldata
        uint256 _nonce, // _nonce
        uint256 chainid // chainid
    ) public pure returns(bytes32){
        bytes32 safeTxHash =
            keccak256(
                abi.encode(
                    to,
                    value,
                    keccak256(data),
                    _nonce,
                    chainid
                )
            );
            return safeTxHash; // trx hash bytes
    }
}

