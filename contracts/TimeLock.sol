// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
Time Lock is a mechinism that can ensure no one can call the specific function before the end of the time.

What is logics in it?
    - Project owner can set the period of time and own the contract when they are creating the contract
    - Time lock has 3 features:
        1. Create Transaction, and push the time lock queue
        2. Execute the transaction when the time lock is end
        3. Cancel some transactions when they are regert
    - Project owner geneary set the time lock contract to be the most important admin,
         such as vault contract, and user Time Lock to call it.
    - the admin of time lock contract usually is the mutiple signature wallet owned by project to ensure the decentrice.

**/
contract Timelock{
    // tx cnacel event
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    // tx execute event
    event ExecuteTransaction(bytes32 indexed txHash, address indexed targret, uint value, string signature, bytes data, uint executeTime);
    // tx enter queue event
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,bytes data, uint execuTime);
    // change admin address event
    event NewAdmin(address indexed  newAdmin);

    address public admin;
    uint public constant GRACE_PERIOD = 7 days; // tx valid period, outdata will expires
    uint public delay;// tx lock time (seconds)
    mapping(bytes32 => bool ) public queueTransactions; // txHash -> bool, record all txs in time lock queue

    modifier onlyOwner(){
        require(msg.sender == admin, "TimeLock: caller not admin");
        _;
    }
    // onlyTimeLock modifier
    modifier onlyTimeLock(){
        require(msg.sender == address(this), "TimeLock: caller not TimeLock");
        _;
    }

    // initialize the lock time (seconds) and admin address
    constructor(uint delay_){
        delay = delay_;
        admin = msg.sender;
    }

    // change admin
    // changeAdmin() is also some kind of transaction!!!  dont forget it.
    // No direct call, we can call it using executeTransaction(), so the onlyTimeLock modifier will pass!
    function changeAdmin(address newAdmin) public onlyTimeLock{
        admin = newAdmin;
        emit NewAdmin(newAdmin);
    }

    function queueTransaction(
        address target, uint256 value, string memory signature, bytes memory data, uint256 executionTime
    )public onlyOwner returns(bytes32){
        // check: execution time is after the end of lock time
        require(executionTime >= getBlockTimestamp() + delay, "TimeLock:: queueTransaction: Estimated execution block ");
        // calculate the unique identification: the hash of a lot of things
        bytes32 txHash = getTxHash(target, value, signature, data, executionTime);

        // queue the transaction
        queueTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executionTime);
        return txHash;
    }

    // cancel specific transaction
    // require: transaction is already in the queue of time lock
    function cancelTransaction(
        address target, uint256 value, string memory signature, bytes memory data, uint256 executionTime
    ) public onlyOwner{
        // calculate the hash of transaction identification : the hash of a lot of things.
        bytes32 txHash = getTxHash(target, value, signature, data, executionTime);
        // check: the transaction is already in the queue of time lock 
        queueTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executionTime);
    }

    // execution some specific transactions
    // not only outside transactions, but also changeAdmin() that is also some kind of transaction
    // requier:
    //      1. the transaction is in the queue of time lock
    //      2. the lockTime is end
    //      3. transaction is not expires
    function executeTransaction(
        address target, uint256 value, string memory signature, bytes memory data, uint executionTime
        ) public payable onlyOwner returns(bytes memory){
            bytes32 txHash = getTxHash(target, value, signature, data, executionTime);
            // check: transaction is in the queue of the time lock
            require(queueTransactions[txHash],"TimeLock::executeTransaction: transaction hasn't been queued");
            // check: the lockTime is end
            require(getBlockTimestamp() >= executionTime, "TimeLock::executeTransaction: transaction hasn't surpassed time");
            // check: transaction is not expires
            require(getBlockTimestamp() <= executionTime + GRACE_PERIOD, "TimeLock::executionTransaction: transaction is stale");
            // remove the transacton from queue
            queueTransactions[txHash] = false;

            // get call data
            bytes memory callData;
            if(bytes(signature).length == 0){
                callData = data;
            }else{
                callData = abi.encodePacked(bytes4(keccak256(bytes(signature))),data);
            }
            // using call() to execute transaction
            (bool success, bytes memory returnData) = target.call{value: value}(callData);
            require(success,"TimeLock::executeTransaction: Transaction execution reverted.");

            emit ExecuteTransaction(txHash, target, value, signature, data, executionTime);

            return returnData;

    }




       /**
     * @dev 获取当前区块链时间戳
     */
    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

       /**
     * @dev 将一堆东西拼成交易的标识符
     */
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }





}