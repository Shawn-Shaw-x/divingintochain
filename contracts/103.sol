// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "./IERC20.sol";

/**
ERC20
ERC20 is a standard that implement the transfertation process oftoken in etherium.
IS the full contract code of standard.
    - balanceOf()
    - transfer()
    - transferFrom() approve Transfer    
    - approve()
    - totalSupply()
    - allowance()
    - name()/symbol()/decimals()

IERC20
IERC20 is a standard interface of ERC20. 
2 events
    // transfer 'value' from an account to another account
    1. Transfer(address indexed from, address indexed to, uint256 value);
    // approve 'value' from owner to spender.
    2. Approval(address indexed from, address indexed spender, uint256 value);
6 functions
    1. totalSuply()
    2.balanceOf()
    3.transfer()
    4.allowance()
    5.approve()
    6.transferFrom()


**/
contract ImplErc20 is IERC20{
    // record the balance
    mapping(address => uint256) public override balanceOf;
    // record the allowance
    mapping (address => mapping(address => uint256)) public override allowance;

    // record the token info
    uint256 public override totalSupply;
    string public name;
    string public symbol; 
    uint8 public decimals = 18;

    // create token info
    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    } 

    // tranfer from sender to receipient 
    function transfer(address receipient, uint amount) public override returns(bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[receipient] += amount;
        emit Transfer(msg.sender, receipient, amount);
        return true;
    }
    // approve
    function approve(address spender, uint amount) public override  returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    // approve and transfer from sender to receipient.
    function transferFrom(address sender, address receipient, uint amount) public override  returns(bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[receipient] += amount;
        emit Transfer(sender, receipient, amount);
        return true;
    }
    // 'mint' is not in IERC20, but allow someone to mint some tokens;
    // should be minted by owner(not implement here)
    function mint(uint amount) external{
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }
    // 'burn' is not in IERC20 
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}

contract TokenFaucet{
    uint256 public amountAllowed = 100; // 100 everyTime
    address public tokenContract; // token address
    mapping(address => bool) public requestAddress; // record the address aleady got tokens

    // sendToken event
    event SendToken(address indexed Receiver, uint256 indexed Amount);

    // set token Contract
    constructor(address _tokenContract){
        tokenContract = _tokenContract;
    }

    // get tokens function 
    function requestTokens() external {
        require (!requestAddress[msg.sender], "Can't request multiple times!");
        IERC20 token = IERC20(tokenContract); // create contract of IERC20
        require(token.balanceOf(address(this)) >=  amountAllowed, "Faucet Empty!"); // not enougth amount
        token.transfer(msg.sender, amountAllowed); //send token  
        requestAddress[msg.sender] = true; // record the address
    
         emit SendToken(msg.sender, amountAllowed); // emit SendToken event
    }
}

/**
airdrop contract

**/
contract Airdrop{

   mapping(address => uint256) failTransferList;

    // calculate the sum of token
    function getSum(uint256[] calldata _arr) public pure returns(uint sum){
        for(uint i = 0; i < _arr.length; i++){
            sum = sum + _arr[i];
        }
    }

    /// @notice send token to multiple address(need approve)
    function multiTransferToken(
        address _token, //token address
        address[] calldata _addresses, // to be transfer address
        uint256[] calldata _amounts // to be transfer amount
    ) external {
        // check the array length of address[] and _amount    
        require(_addresses.length == _amounts.length, "length of addresses and amounts not equal!");
        IERC20 token = IERC20(_token);// declare the varible of IERC20 contract
        uint _amountSum = getSum(_amounts); // calculate the sum of tokens
        // check: approve tokens >= airdrop tokens
        require(token.allowance(msg.sender, address(this))>= _amountSum, "need approve token");

        for(uint8 i; i < _addresses.length; i++){
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }

    // send ETH to multiple address
    function multiTransETH(
        address payable[] calldata _addresses,
        uint256[] calldata _amounts
    ) public payable {
            // check: check the equality of _addresses and _amounts
            require(_addresses.length == _amounts.length, "Lengths of Addresses and Amounts NOT EQUAL");
            uint _amountSum = getSum(_amounts); // calculate the sum of all airdrops
            // check the all ETH equal to all airdrops
            require(msg.value == _amountSum, "transfer amount error");
            // for loop to transfer ETH
            for (uint i=0; i< _addresses.length; i++){
                // 注释代码有Dos攻击风险, 并且transfer 也是不推荐写法
                // Dos攻击 具体参考 https://github.com/AmazingAng/WTF-Solidity/blob/main/S09_DoS/readme.md
                // _addresses[i].transfer(_amounts[i]);
                (bool success, ) = _addresses[i].call{value: _amounts[i]}("");
                if(!success){
                    failTransferList[_addresses[i]] = _amounts[i];
                }
            }
    }
}





