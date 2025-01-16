// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";



/**
What is Token Lock?
    It is a contract base on time lock which can lock the tokens in the contract for a period of time.
    Beneficiary can withdraw the tokens after the lock-up preiod time expires.
    Token Lock generally is used to lock liquidity provider LP tokens.
What is LP token?
    In DEX exchanger, they use AMM mechanisms. So it need users or project owners to provide fund pool
     which can let other users buy or sell instantly.
     Simply speaking, user/project pledge their token pair (ETH/DAI) to the fund pool. 
     And DEX will give them LP tokens that means they have pledged equal shares.
    
Why need to lock liquidity?
    If project owner withdraw LP token from the pool, other invester's token will be zero  which is called rug-pull.
    So we need to lock the LP token in the contract. And before the end of lock-up period,
     project owner can not withdraw the LP token. This measure avoid from rug-pull attack.
**/
contract TokenLocker {

    event TokenLockStart(address indexed  beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    // ERC20 token to be locked
    IERC20 public immutable token;
    // benificiary address
    address public immutable beneficiary;
    // lock time (seconds)
    uint256 public immutable lockTime;
    // start time timestamp
    uint256 public immutable startTime;

    // deployment the contract of time lock,
    // initialize the address of the token/beneficiary/lock time
    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 lockTime_
    ) {
        require(lockTime_ >0 ,"TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;
        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }
    /**
        Release token to beneficiary after the end period of lock-up time
    **/
    function release() public {
        require(block.timestamp >= startTime + lockTime, "TokenLock: current time is before release time.");
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");
        token.transfer(beneficiary, amount);
        emit Release(msg.sender, address(this), block.timestamp, amount);
    }
}