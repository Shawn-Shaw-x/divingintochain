// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
What is payment split?
    Split rule is coded on contract that money automatly are splited into specific addrss.
What features split has?
    1. Already defined payees and shares before  running the contract.
    2. Shares could be equal or specific propotion.
    3. Every payees can withdraw their shares of amount when the contract have received ETH.
    4. The contract follow the Pull Payment mode which means the payment will not into the account but the contract.
        And payees need to call the release() function to triger actual transfer.


**/

// Split contract
contract PaymentSplit{
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 public totalShares; // total shares(all sum of share)
    uint256 public totalReleased; // total payment(all ETH transfer from contract to payees)

    mapping(address => uint256) public shares ; // every payees' shares
    mapping(address => uint256) public released; // amount that pay to every payees
    address[] public payees; // payees array

    /**
        initilaze the _payees and _shares
        the length of array can not be 0 and the length need to be equal.
         the element of _shares need larger than 0. 
         the address of _payees cannot be 0 and unrepeatable.
    **/
    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        // check _payee and _shares length, 0 
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");
        // call _addPayee, update the address of payee/ shares/ totalShares
        for(uint256 i = 0; i < _payees.length; i++){
            _addPayee(_payees[i], _shares[i]);
        }
    } 

    /**
        callback function, receive ETH and emit the PaymentReceived event
    **/
    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
        Split for the payees' address. Send the ETH to their address.
        Everyone can call this function, but the money will transfer to the account
    **/
    function release(address payable _account) public virtual{
        // account need to be valid.
        require(shares[_account] > 0,"PaymentSplitter: account has no shares");
        // calculate the ETH that account should be transfered to.
        uint256 payment = releasable(_account);
        // abaliable ETH can not equal to 0
        require(payment != 0, "PaymentSplitter: account is not due payment");
        // update the totalReleased and pay to every payees.
        totalReleased += payment;
        released[_account] += payment;
        // transfer
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    /**
        Calculate the account that how much ETH it can gain. 
    **/
    function releasable(address _account) public view returns(uint256){
        // calculate the total income totalReceived
        uint256 totalReceived = address(this).balance + totalReleased;
        // call _pendingPayment to calculate the deserved ETH
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    /**
        Using the _address/ _totalReceived/ _alreadyReleased to calculate the deserved ETH of payees
    **/
    function pendingPayment(
        address _account,
        uint256 _totalReleased,
        uint256 _alreadyReleased
    ) public view returns (uint256){
        // deserved ETH = all deserved ETH - already gain ETH
        return (_totalReleased * shares[_account]) / totalShares - _alreadyReleased;
    }

    /**
        Add payees
        Add _account and _account's shares
        This function must be called in constructor, and can not be called in other place.
    **/
    function _addPayee(address _account, uint256 _accountShares) private {
        // check the _account address can not equal 0
        require(_account != address(0), "PaymentSplitter: account is the 0 address");
        // check the _accountShares can not equal 0
        require(_accountShares > 0, "PaymentSplitter: shares are 0");
        // check: the _account is unrepeatable.
        require(shares[_account] == 0, "PaymentSplitter: account already has shares");
        // update payees, shares and totalShares
        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;
        // emit the event of PayeeAdded
        emit PayeeAdded(_account, _accountShares);

    }



}