// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract testFunction{
    // variable on contract
    // 1. valueType: int,bool...
    // 2. refernce Type: array and struct 
    // 3. mapping Type: hash map

      uint thisUint = 1;

      /**
        read and write on contract
      **/
    function add() external   {
        thisUint = thisUint+1; // read the variability on contract, consume gas fee 
    }
    /**
    Pure cannot read or write,
    **/
    function addNoFee(uint _number) external pure returns(uint _newNumber)  {
        _newNumber = _number + 1; // use with internal variability and return variability, dont need to consume gas
    }
    /**
    view can read, but cannot write the variability on contract
    **/
    function addWithView() external view returns(uint _newNumber){
        _newNumber = thisUint + 1; // pure can read ,but cannot write the variality on contract , donnt need to consume gas
    }

    /**
    internal visited only by internal on contract 
    **/
    function minus() internal {
        thisUint = thisUint -1;
    }
    /**
    external visited by inside or outside on contract 
    **/
    function minusCall() external {
        minus();
    }

    /**
    payable give money(eth) , special function that can pay money with eth
    **/
    function minusPayble( ) external payable returns(uint256 balance){
        minus(); // call the internal function
        balance = address(this).balance; // transfer money to this contract 
    }
    /**
    return and returns
    return would be used in the inside of function
    return would be used in the declare of function to dedicate the return of variable 
    BTW, we use uint256[3] to declare the quote variability and must be dec with memory.
        because of the [1,2,3] will be transfer to uint8, we need uint256(1) to transfer the array to uint256 
    **/
    function returnMultiple() public pure returns(uint256,bool,uint256[3] memory) {
        return (1,true,[uint256(1),2,5]);
    }

    /**
    named return
        in this case, we declare the returns variability in advanced, 
        so we donnot need declare return inside of the function,
        all we need to do is give the value to the variability.
        but you sill can use the return in this case if you want.
    **/
    function returnNamed() public  pure returns(uint256 _number,bool _bool,uint256[3] memory _array){
        _number = 2;
        _bool = false;
        _array = [uint256(3),2,1];
    }

    /**
    Destructuring Assignment
        in this case, we use destracturing assignment to destract the variable
        all variable will be included by '()'
        each variable will be separate by ','
    **/
    function destructVariable() external view returns(uint256 _number,bool _bool,uint256[3] memory _array){
        // uint256 _number;
        // bool _bool;
        // uint256[3] memory _array;
        (_number, _bool, _array) = this.returnNamed();
        // also you can use below code to destruct the part of variable,
        // all you need to do is leave the empty for the position of variable
        // (, _bool,) = this.returnNamed();

    }

    /**
    data location 
    in this case ,we discuss the location of data, for reference data,there are three location in the blockchain 
        1. storege: default in normal contract 
        2. memory: save in memory, donnot need to save in the chain,
             especially in the data that is not fixed length. such as 'string'/'bytes'/'array'/'struct'
        3. cell data: simple as memory, save in local memory,but differ as it is immutable, normally be used in function variable
            function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
                // _x[0] = 0 //这样修改会报错
                return(_x);
                }
    **/

    /**
    reference and value type 
        for reference type, change the reference value means to change the original value.
        for the others, change it means to copy a new value.
    **/
    uint[3] x = [1,2,3];
    function fstorage() public {
        // declare a variable refer to x, change it means to change the x
        uint[3] storage xStorage = x;
        xStorage[0] = 100;
    }

    /**
    scope in variable
        there are 3 scope in contract
        1. state: saved in chain, state will be declare inside the contract but outside the function. high gas fee
            such as the thisUint 
        2. local:  saved inside the function, used in the progress of function. low gas fee.
        3. global:  preserved keyword by solidity, can be used withour declaration. 
    
    **/
    function fGlobal() external view returns(address, uint, bytes memory){
        address sender = msg.sender; // current caller
        uint blockNumber = block.number; // current block length
        bytes memory data = msg.data; // current full cellData 
        return(sender, blockNumber,data);
    }


    /**
    ether money
    in order to avoid the precision loss in solidity, it use the '0' to  represent the dot
    wei 1
    gwei 1e9 1*10^9
    ether 1e18  1*e18

    time 
        seconds: 1 seconds
        minutes: 1 minutes = 60 seconds 
        hours: 3600 seconds
        days: 86400 seconds
        weeks: 604800 seconds

    **/

    /**
    reference Type
        array
            1. fixed length
            2. dynamic array
    **/
    function arrayType() pure external {
        // fixed length
        uint[8] storage array1;
        bytes[8]  storage array2;
        address[100] storage array3;

        // dynamic length
        uint[] storage array4;
        bytes1[] storage array5;
        address[] storage array6;

        /**
            remember: bytes is a special array, donnot need '[]',
            BTW, cnnnot use 'bytes[]' to declare the array,
            and you can use bytes1[] to declare the array,
            BTW, using bytes is more cheaper than bytes1[].
        **/
        bytes storage array7;  

        /**
        there are some rules in cratation of array
        1. if you decorate it with 'memory', you can use 'new' to create an array. but you need to indicate the length of array.
        2. if you are not indicate the length of uint, it will use the uint8 for default length 
        **/
        uint[] memory array8 = new uint[](5);
        bytes memory array9 = new bytes(9);
        // you need assign the value one by one in this creation
        array8[0] = 1;
        array8[1] = 2;

        // array has it own methon such as push()/push(x)/pop()/length
        // btw push() means push '0’' in the last of array and return the reference of this element
        // push(x) meas push 'x' in the last of array 

    }
        /**
         struct 
          you can assign the values with 4 different ways
        **/
            struct Student{
                uint256 id;
                uint256 score; 
            }
            Student student; // 初始一个student结构体
    // 1. Using the reference
    function initStudent1() external  {
        Student storage _student = student; // assign a copy of student
         _student.id = 11;
         _student.score = 100;
    }
    // 2. Using the state variable directly
    function initStudent2() external{
        student.id = 1;
        student.score = 80;
    }
    // 3. constructor function 
    function initStudent3() external {
        student = Student(3, 90);
    }
    // 4. key & value
    function initStudent4() external {
        student = Student({id: 4, score: 60});
    }

    /**
    mapping 
        you can use below code to declare a map
            mapping(uint => address) public idToAddress;
            mapping(address => address) public swapPair;
        there are some rules when you use the mapping 
            1. only keyword of solidity can be used in keyType such as uint, address
                struct can be used in valueType
            2. the location of mapping must be 'storage'
            3. if the mapping is declared by 'public', a getter will be generated by solidity.
            4. if you want to add a pair of mapping , '_Var[_Key] = _Value' can be used
    **/

    /**
        in solidity, the variable has it own default value when it is not assign.
            boolean: false
            string: ""
            int: 0
            uint: 0
            enum: the first element
            address: address(0)
            function:
                internal: empty
                external: empty
            mapping: default mapping
            struct: every part of value is it own default value
            array:
                dynamic:[]
                static: every part of value is it own default value

        BTW, 'delete' a variable will set the variable default
    **/



    /**
    constant and immutable
        the gas fee will cheeper  declaring this two keyword 
        BTW, only value type can be declared 'constant' and 'immutable'
        'string' and 'byte' can be declared to 'constant',but not 'immutable'
    **/

    /**
    constant
        'constant' varible must be init when declaring, and cannot be change later
        'immutable' variable can be init when declaring or construct function, 
            if 'immutable' variable is init in declaration also constructor function,
            construction would be the priority.
    **/

    /**
    insert sort 
    test [2,5,3,1]
    **/
    function insertSort(uint[] memory a) external pure returns (uint[] memory){
        for(uint i = 0; i<=a.length-1; i++){
            for(uint j = i+1; j<=a.length-1; j++){
                if(a[i]>a[j]){
                   uint tem = a[i];
                    a[i] = a[j];
                    a[j] = tem;
                }
            }
        }

        return a;

    }

    /**
    constractor and modifier
        1. constractor is a pecial function that only one constractor can be defined by every single constract.
            It will run automatually when the constract be deployed.
        2. modifier is a special gramma in solidity, it is simple as the 'decorator' of other language
            It is usually used in running check befor running a  function,such as checking addrss/variable/balance

    **/

    address owner; // define owner variable

    // constract function 
    // constructor(address initialOwner) {
    //     owner = initialOwner; // when deploying, owner will get the address of initalOwer
    // }

    modifier onlyOwner {
        require(msg.sender == owner); // check sender == owner
        _; // leave blank
    }

    // Before running this function , it will run modifier automatully.
    function changeOwner(address _newOwner) external onlyOwner{
        owner = _newOwner; // only owner address can run this function and change owner
    }

    /**
     solidity event
    event is a abstract of log in EVM
    event has 2 features:
        1. response: ether.js can subscribe and listen this event and take responses whth it
        2. ecnomic: event is a ecnomic way to save datas, less than save variable in chain
    **/

    /** 
    declare event
    
    as we can see, the event of Transfer has 3 variable, from/to and value. 
    'indexed' represent it will be save in EVM  topics of log for index.
    **/
    event Transfer(address indexed from, address indexed to, uint256 value);

    mapping(address => uint256) public _balances;  // define a mapping to save balances
      function _transfer(
        address from,
        address to,
        uint256 amount
        ) external {
            _balances[from] = 123456789; // init some coin for 'from' address
            _balances[from] -= amount; // 'from' address decrease some coins
            _balances[to] += amount; // 'to ' address add some coins

        emit Transfer(from,to,amount); // emit event 
    }

    /**
    EVM logs
    EVM use log to record the event of solidity, every logs contain topics and data
    - topic: describe event, less than 4 in length, the first element is singnature(hash)
            besides, topic can contain 'indexed' paragrams, if it is too large for index ,
            it will be calculate as hash to save in topic such as 'string'
    - data: data will contains the paragrams that is not being 'indexed'
            it is no length limit and its gas fee is less than topic
    **/


}

contract grantfather{

        /**
    inheritance 
    'virtual' : keyword to be used in father contract, if you need rewrite it in son contract, you will need it.
    'override': if son contract rewrite the father's function, you will need it.
    **/
        event Log(string myMessage);

        function say() public virtual {
            emit Log("i am grantfather");
        }
        function speak() public virtual {
            emit Log("i am grantfather");
        }
        function talk() public  virtual {
            emit Log("i am grantfather");
        }

        
    }
    contract grantmother{

        

        function say() public virtual {
            string memory  _myname = "momo";
        }
   
    }

        contract father is grantfather{
        // event MyLog(string myMsg);

        function say() public virtual  override  {
            emit Log("i am father");
        }
        function speak() public virtual override {
            emit Log("i am father");
        }
        function talk() public virtual override {
            emit Log("i am father");
        }
    }

    /**
    multiple inheritance
    1. when inheritage from grantFather to father , you need to code roderly like 'son is father, grantfather'
    2. if a function exit both in father and grantfather, it must be override 
    3. override a function with same name both in father and grantfather, 
        all father contract name must be added  'override' to the end
    **/
    contract son is grantfather,grantmother{
        // inhertage both father, it need to add both of them to the end of 'override'
        function say() public virtual override(grantfather,grantmother){
            emit Log('i am a son');
        }

    }

    /**
    BTW, 
        1.modifier  also can be inheritaged
        2.constructor  also can be inheritaged
    **/

    
    contract Base1 {
         uint public a;
        event Log(string messages);
        modifier doSomethingBefore(uint _a) virtual {
            emit Log("this is before modifier");
            _; // leave empty to be full;
        }

        function  doSomethingBase() public   {
            emit Log("do something base");
        }

        constructor(uint _a){
            a = _a;
        }
    } 

    contract Identifier is Base1 {
        // do so it will inheritage father's constructor
        // contract  Identifier is Base1(1)
        // or 

        // redifine constructor in son contract 
        constructor(uint _c) Base1(_c){}

        // do so ,it will overrive father's modifier
        modifier doSomethingBefore(uint _a) override {
            emit Log("this is updated modifier");
            _;
        }

   
        function mainFunction(uint _a)  public doSomethingBefore(_a)  returns(uint, uint){
            return (_a, _a+1);
        }

        function callFatherFunction()  external   {
            // you can use super or father's contract name to call the function
            super.doSomethingBase();
            Base1.doSomethingBase();
        }
    
}

        /**
        diamond inheritance
        in OOP, diamond inheritance means a class inherit from two or above classes
        - if you call a same named function using 'super' in diamond inheritance,
             you will call every function in it's father class

        
                God
                /  \
                Adam Eve
                \  /
                people

        the sequences is Eve.foo()->Adam.foo()->God.foo()
                **/
contract God{
    event Log(string mesage);
    function foo() public virtual{
        emit Log("God.foo called");
    }
    function bar() public virtual{
        emit Log("God.bar called");
    }       
}
contract Adam is God{
    function foo() public virtual override {
        emit Log("Adam.foo called");
        super.foo();
    }
    function bar() public  virtual override {
        emit Log("Adam.bar called");
        super.bar();
    }
}
contract Eve is God{
    function foo() public virtual override {
        emit Log("Eve.foo called");
        super.foo();
    }
    function bar() public virtual override {
        emit Log("Eve.bar called");
        super.bar();
    }
}
contract People is Adam, Eve{
    function foo() public override(Adam, Eve){
        super.foo();
    }
    function bar() public override(Adam, Eve) {
        super.bar();
    }
}


    /**
    abstract contract and interface
    1. abstract contract:
        - a contract only has one unimplement function(without {}), it must be 'abstract'
        - that function must be added 'virtual'
    2. interface:
        - cannot contain any state varible
        - cannot contain any constructor 
        - cannot inheritage any other contract except for 'abstract'
        - all functions must be 'external' and without '{}'
        - all contracts that implement interfaces must implement all functions in interfaces;
    **/

    /**
    IERC721 to BAYC
    **/
// contract iteractBAYC{
//     // using BAYC address to create variable of contract (ETH mainnet)
//     IERC721 BAYC = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

//     function balanceOfBAYC(address owner) external view returns(uint256 balance){
//         return BAYC.balanceOf(owner);
//     }
//     function safeTransferFromBAYC(adderss from, address to, uint256 tokenId) external {
//         BAYC.safeTransferFrom(from, to, tokenId);
//     }
// }
  

  /**
  exception
  1. Error // less gas fee than others
  2. require(bool,message)
  3. Assert(bool)
  **/
contract testError{
    error TransferNotOwner();
     mapping(uint256 => address) _owner;
    
    // customize error
    function transferOwner1(uint256 tokenId, address newOwner) public {
        bytes32  randomBytes = keccak256(abi.encodePacked(block.timestamp));
        _owner[256] =  address(uint160(uint256(randomBytes)));
        if(_owner[tokenId] != msg.sender){
            revert TransferNotOwner(); // error has to use with revert
        }
        _owner[tokenId] = newOwner;
    }

    // throw error with messages
    function transferOwner2(uint256 tokenId, address newOwner) public {
        bytes32  randomBytes = keccak256(abi.encodePacked(block.timestamp));
        _owner[256] =  address(uint160(uint256(randomBytes)));
        require(_owner[tokenId] == msg.sender, "Transaction Not Owner");
        _owner[tokenId] = newOwner;
    }

    // only throw error
    function transferOwner3(uint256 tokenId, address newOwner) public {
        assert(_owner[tokenId] == msg.sender);
        _owner[tokenId] = newOwner;
    }
}

/**
    receive ETH

    receive() is a function that will be execute when  the contract has received ETH
    - this function must be 'payable' and 'external' 
    **/
contract ETHReceiver{
    // define an event
    event Received(address sender, uint value);
    // receive ETH and emit event
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
    fallback
        fallback() is a function that can be used to receive ETH and to do proxy contract
        - fallback() must be 'payable' and 'external'    

    **/
    event FallbackCalled(address Sender, uint Value, bytes Data);
    //fallback 
    fallback() external payable{
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }

    /**
    the differences between receive() and fallback()
            fallback() or receive()?
                get ETH
                    |
                msg.data is empty？
                    /  \
                yes    no
                /      \
        receive()exist?   fallback()
                / \
            yes  no
            /     \
        receive()   fallback()



        if you send ETH to contract, it will check the msg.data. if empty, receive() will be execute. otherwise, fallback will be execute.
        also, non of receive() and fallback() exist in the contract, it will occur an error. 
        **/
} 

/**
    send ETH
    in solidity, there are three way to send ETH to another contact
    - call(): the most useful function to send ETH
        1. usage: receiver.call{amount}
        2. there is no gas limit in 'call()', receiver can do some complex logic in it.
        3. if call() fail, it will not revert
        4. returns of call() is (bool, bytes), bool means success or fail.

    - transfer():
        1. usage: receiver.transfer(amount)
        2. the limit of gas in transfer() would be 2300, enough for send ETH, but receiver contract cannot do more complex logi in fallback() or receive()
        3. if some fail occur in transfer(), revert will be run automatally.

    - send():
        1. usage: receiver.send(amount)
        2. the limt of gas in send() would be 2300, enough for send ETH, but receiver's contract cannot do more complex logi in fallback() or receice()
        3. if fail, revert will not be run.
        4. the return of send() is bool, it means the result of send ETH.
**/

contract testSendETH{
    error CallFailed(); // if call() fail, it will be throw
    // call() to send ETH
    function callETH(address payable _to, uint256 amount) external payable {
        // catch the return of call(), if fai, revert transaction and return error
        (bool success,) = _to.call{value: amount}("");
        if(!success){
            revert CallFailed();
        }
    }

}

// contract be invoked
contract OtherContract{
    uint256 private _x = 0; // state variable _x
    event Log(uint amount, uint gas);


    function getBalance() view public returns(uint){
        return address(this).balance;
    }

    function setX(uint256 x) external payable{
        _x = x;
        // if sendETH, release event Log
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }

    // read X
    function getX() external view returns(uint x){
        x = _x;
    }
}

// contract call other contract
contract CallContract{
    // call OtherContract through contract address, 
    function callSetX(address _Address, uint256 x) external{
        OtherContract(_Address).setX(x);
    }
    // call OtherContract through contract name
    // BTW the lower type of contract name is still address
    function callGetX(OtherContract _Address) external view returns(uint x){
        OtherContract oc = OtherContract(_Address);
        x = oc.getX();
    }
    // same as upon
    function callGetX2(address _Address) external view returns(uint x){
        OtherContract oc = OtherContract(_Address);
        x = oc.getX();
    }

    //  OtherContract is payable, we can use it to transfer ETH
    // All we need to do is add 'payable' in CallContract

    function setTransferETH(address otherContract, uint256 x) payable external{
        OtherContract(otherContract).setX{value: msg.value}(x);
    }
}

/**
call() is low level function of address, it can be used to intereact with other contract.
(bool,types) is it's returns
    1. 'fallback()' and 'receive()' can be trigged by  call() when sedding ETH
    2. invoked another contract by call in not recommand , 
         because when you invoke another unsafe contract by 'call()',
          you are taking the initiative 
        - you should invoke another contract's function by invoking function after declaring varibale
    3. we still can invoke another contract's function by 'call()' when we don't know other contract's source code or ABI.
    4. contract'sAddress.call(bytes) is the rules. 'bytes' can be encoded by 'abi.encodeWithSignature()'
        example: abi.encodeWithSignature("functionSignatureString", detailArgs);
**/

contract BeingCallContract{
    uint256 private _x = 0; // state variable _x
    fallback() external payable { }
    event Log(uint amount, uint gas);


   function getBalance() view public returns(uint) {
        return address(this).balance;
    }
    function setX(uint256 x) external payable{
        _x = x;
        // if sendETH, release event Log
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }
        // read X
    function getX() external view returns(uint x){
        x = _x;
    }
}
contract DoingCallContract{
    // define a Response event , get the success and data when calling 'call()'
    event Response(bool success, bytes data);

    // call getX() and you can transfer ETH
    function callSetX(address  payable  _addr, uint256 x) public payable {
        // call setX(), also can send ETH
        // msg.value means amount of ETH
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("setX(uint256)", x)       
        );
        emit Response(success, data); // emit event
    }

    // call getX but you can't transfer ETH
    function callGetX(address _addr) external returns (uint256){
        // call getX, not payable ,so it cannot be transfered ETH
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );
        emit Response(success, data);
        return abi.decode(data, (uint256));
    }

    // call function do not exit 
    // if we call a function not exit in BeingOtherContract, this call still can be success,
    // because the fallback() in BeingOtherContract will be called.
    function callNotExit(address _addr) external {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("foo(uint256)")
        );
        emit Response(success, data);
        
    }
}

/**
delegate call
    delegatecall is same as call, which is the low level of address.
    when user A call contract B, contract C's function will be invoked

    normal call:
    -----             -----------             -----------
   |userA| --call--> | contractB |  --call-->| contractC |
    -----             -----------             -----------
                      contex: B                 contex: C
                      msg.sender: A             msg.sender: B
                      msg.value: A              msg.value: B

    delegateCall:
    -----             -----------                     -----------
   |userA| --call--> | contractB |  --delegateCall-->| contractC |
    -----             -----------                     -----------
                      contex: B                         contex: B
                      msg.sender: A                     msg.sender: A
                      msg.value: A                      msg.value: A
    
    Same as call(), delegateCall can be used as 'targetAddress'.delegatecall(byteCodes);
    bytecodes can be constructed as 'abi.encodeWithSignature('functionSignature',args)'
    fuctionSignature can be constructed as 'functionName(uint256,address)' etc.

    - different from call, delegatecall can define gas but cannot define ETH
    - notes: delegatecall have some security problems.
     when it is used, you need to ensure that current contract have the same variable structure as target constract
     and target constract is a safety constract.

     delegatecall mainly be used in below two scenerio
     1. Proxy Contract:
        seprate storage contract from logic contract.
         we are going to save logic contract address and all variable in proxy contract,
         and we save logic in logic contract.
         when we are going to update, we just need to change the address in proxy contract.
     2. EIP-2535 Diamonds:
        Diamonds is a standard which can build a smart contract system that can extend module in production environment.

**/

// c to be invoked
contract C {
    uint public num;
    address public sender;
    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}
// B to invoke
contract B{
    // must be as same as C
    uint public num;
    address public sender;

    // call will change the variable of C
    function callSetVars(address _addr, uint _num) external payable{
        // call setVars()
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
    // delegatecall will change the variable of B
    function delegatecallSetVars(address _addr, uint _num) external payable{
        // delegatecall setVars()
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}

/**
create a new contract in a contract

    there are two way to create a new contract 
    1. create: new Contract{value: _value}(params)
        Contract is name, x is address, if constractor is 'payable', 
        it can transfer _value to this contract, params is the new contract params
    2. create2: create2 provide a feature that the contract address can be predicted before deploy
        Uniswap use 'create2' to create Pair rather than 'create'

        how to calculate address?
        - create: newAddress = hash(creatorAddress, nonce) 
                    nocce: that address' transactions count
        - create2: new Address = hash("0xFF", creatorAddress, salt, initCode)
                    'OXFF': constant 
                    salt: bytes32 value, defined by creator
                    initcode: newContract's initCode

        how to use create2?
        - Contract x = new Contract{salt: _salt, value: _value}(params)

        Why we need create2?
        1. Exchange save the wallet address for user in advance
        2. Make it certain,  we donnot need to run 'Factory.getPair(tokenA, tokenB)' to implement the cross contract invoking.
           Because the pair in newContract is fixed. we can calculate the pair in Router by (tokenA, tokenB).
**/

/**
simple uniswap
1. UniswapV2Pair: coin pair contract, used to manage pair address/liquid/buy and sell
2. UniswapV2Factory: factory contract, used to create new pair and manage pair address
**/

contract Pair{
    address public factory; // factory contract address
    address public token0; // pair1
    address public token1; // pair2

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external{
        require(msg.sender == factory, 'UniswapV2:FORBIDDEN');
        token0 = _token0;
        token1 = _token1;
    }
}
contract PairFactory{
    mapping(address => mapping(address => address)) public getPair; // looked Pair address by two coin address
    address[] public allPairs; // save all Pair address

    function createPair(address tokenA, address tokenB) external returns(address pairAddr){
        // create a new contract
        Pair pair = new Pair();
        // invoke the initilize()
        pair.initialize(tokenA, tokenB);
        // update to address map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }
}



contract Create2Pair{
    address public factory; // factory contract address
    address public token0; // pair1
    address public token1; // pair2

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external{
        require(msg.sender == factory, 'UniswapV2:FORBIDDEN');
        token0 = _token0;
        token1 = _token1;
    }
}
contract Create2PairFactory{
    mapping(address => mapping(address => address)) public getPair; // looked Pair address by two coin address
    address[] public allPairs; // save all Pair address

    function create2Pair(address tokenA, address tokenB) external returns(address pairAddr){
        require(tokenA != tokenB,'IDENTICAL_ADDRESSES'); // avoid confict
        // use tokenA and tokenB to calculate salt
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); // sort by size
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // use create2 to deploy
        Create2Pair pair = new Create2Pair{salt: salt}();
        // invoke the initialize in new contract
        pair.initialize(tokenA, tokenB);
        // update address map
        pairAddr = address(pair);
        allPairs.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }

    /**
    calculate pair contract address in advance
    **/
    function calculateAddr(address tokenA, address tokenB) public view returns(address predictedAddress){
        require(tokenA != tokenB,'IDENTICAL_ADDRESS'); // avoid same conflict
        // cal the salt
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);// sort
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        // cal the contract address
        predictedAddress =  address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(type(Create2Pair).creationCode)
        )))));
    }
}
// 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
// 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c


/**
delete contract
    selfdestruct command can be used to delete contract, and transfer the rest ETH to special address.
    - 'selfdestruct' can not be used in deployed contract
    - It must be used in the same transaction, if you want to use the previous selfdestruct

    How to use?
    - selfdestruct(_addr)
        _addr is used to receive the rest ETH.
        _addr do no need receive() or fallback() to receive ETH.  

    Problems:
    1. set 'onlyOwner' in selfdestruct function would be best.
    2. 'selfdestruct' that is used in your project maybe involves some safety and trust problems. So, be careful when you add it in your contract.
**/

/**
Bfore Cancon update
    It can finish the selfdestruct, but after the Cancon update, the only thing it can do is tranfering ETH.=
**/
contract DeleteContract{
    uint public value =10;
    constructor() payable {}

    receive() external payable {}

    function deleteContract() external {
        // invoke 'selfdestruct' and destroy the contract, besides, send the rest ETH to msg.sender
        selfdestruct(payable(msg.sender));
    }
    function getBalance() external view returns(uint balance){
        balance = address(this).balance;
    }
}

/**
according the propusal ,
**/
contract DeployConstract {
    struct DemoResult {
        address addr;
        uint balance;
        uint value;
    }
    constructor() payable {}
        function getBalance() external view returns(uint balance){
        balance = address(this).balance;
    }

    /**
    invoke this function means you are create a DeleteCOntract and send your value to it and destroy it.
    in the end, you can get back your ETH.
    **/
    function demo() public payable returns (DemoResult memory){
        DeleteContract del = new DeleteContract{value:msg.value}();
        DemoResult memory res = DemoResult({
            addr: address(del),
            balance: del.getBalance(),
            value: del.value()
        });
        del.deleteContract();
        return res;
    }
}

/**
ABI encoding
    ABI is a standard that belongs to Etherium's smart contrat.
    1. abi.encode(): encode to 32bytes data
    2. abi.encodePacked(): save space
    3. abi.encodeWithSignature(): used to call the other contract's function
    4. abi.encodeWithSelector(): used to call the other contract's function

    sceneriao:
    1. call low level contract's function.
    2. import and  call the ether.js 
    3. call the contract that is not open-source.
        abi.encodeWithSelector(bytes4(0x533ba33a));

**/

contract ABIEncodeing{
    uint x =10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6];

    // every params will be encoded to data with 32 bytes
    function encode() public view returns(bytes memory result){
        result = abi.encode(x, addr, name, array);
        // result:
        // 0x000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
    } 

    // encoding params with the way of saving space.(ingnoring some 0 in the target)
    // when you do not want to intereact with contract, you can use this way to encode.
    function encodePacked() public view returns(bytes memory result){
        result = abi.encodePacked(x, addr, name, array);
        // result:
        // 0x000000000000000000000000000000000000000000000000000000000000000a7a58c0be72be218b41c608b7fe7c5bb630736c713078414100000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000006
    }

    // As same as the abi.encode(), replaced the first param is 'functionSignature'
    function encodeWithSignature() public view returns(bytes memory result){
        result = abi.encodeWithSignature("foo(uint256,address,string,uint256[2]", x, addr, name, array);
        // result:
        // 0xe87082f1000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
        // used to invoke other contract's function
    }

    // As same as the abi.encodeWithSignature, the firest param is 'functionSelector'
    function encodeWithSelector() public view returns(bytes memory result){
    result = abi.encodeWithSelector(bytes4(keccak256("foo(uint256,address,string,uint256[2])")), x, addr, name, array);
        // 0xe87082f1000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000007a58c0be72be218b41c608b7fe7c5bb630736c7100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000043078414100000000000000000000000000000000000000000000000000000000
        // equals to encodeWithSignature
    }

    // this function is used to decode the binary code generated by abi.encode
    function decode(bytes memory data) public pure returns(uint dx, address daddr, string memory dname, uint[2] memory darray){
        (dx, daddr, dname, darray) = abi.decode(data, (uint, address, string, uint[2]));
    }
}

/**
hash
    A good hash should be 
    - single direction: reverse to calculate is very hard.
    - sensitive: change a little bit in input will change a lot in output.
    - high efficient: calculation efficiency is very high.
    - equality: every values should has the same oppotunity to be calculate.
    - anti-crash: 

    Used to where?
    1. generate ID
    2. singnature
    3. cryptcy

    Keccaak256
        the most useful hash function in Solidity.
        sha3 original from keccak256, but they has some differences.
**/

contract HashContract{
    function hash(
        uint _num,
        string memory _string,
        address _addr

    ) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_num,_string,_addr));
    }
}


/**
Selector
    the core of calling a function of contract is sending a 'celldata' to target contract.
    the first 4 bytes of the calldata sent are selector(function selector).

    Example:

    function mint(address to) external{
    emit Log(msg.data);

    param == '0x2c44b726ADF1963cA47Af88B284C06f30380fC78'    
    celldata is '0x6a6278420000000000000000000000002c44b726adf1963ca47af88b284c06f30380fc78'
    the first 4bytes of celldata sent are selector '0x6a627842'
    the last 32bytes of celldata sent are input params '0x0000000000000000000000002c44b726adf1963ca47af88b284c06f30380fc78'

    method_id is the first 4 bytes before Keccak(functionSignature)

    How to calculate method_id?
        here are some examples for you:
        1. base type param
        2. fixed length param
        3. dynamic length param
        4. mapping type param
}
**/

contract EmptyContract{

}

contract SelectorContract {
    event SelectorEvent(bytes4);

    // base type param
    function elementaryParamSelector(uint256 param1, bool param2) external returns(bytes4 selectorWithElementaryParam){
        emit SelectorEvent(this.elementaryParamSelector.selector);
        // must be uint256
        return bytes4(keccak256("elementaryParamSelector(uint256,bool)"));
    }

    // fixed length param
    function fixedSizeParamSelector(uint256[3] memory param1) external returns(bytes4 selectorWithFixedSizeParam){
        emit SelectorEvent(this.fixedSizeParamSelector.selector);
        return bytes4(keccak256("fixedSizeParamSelector(uint256[3])"));
    }

    // dynamic length param
    function nonFixedSizeParamSelector(uint256[] memory param1, string memory param2) external returns(bytes4 selectorWithNonFixedSizeParam){
        emit SelectorEvent(this.nonFixedSizeParamSelector.selector); 
        return bytes4(keccak256("nonFixedSizeParamSelector(uint256[],string)"));
    }

    struct User{
        uint256 uid;
        bytes name;
    }
    enum School {SCHOOL1, SCHOOL2, SCHOOL3}

    // mapping type
    // contract/enum/struct...

    // contract --> address
    // enum --> uint8
    // struct --> (x,y)
    function mappingParamSelector(EmptyContract demo, User memory user, uint256[] memory count, School mySchool) external returns(bytes4 nonFixedSizeParamSelector){
        emit SelectorEvent(this.mappingParamSelector.selector); 
        return bytes4(keccak256("mappingParamSelector(address,(uint256,bytes),uint256[],uint8"));
    }

    // use Selector to call function 
    function callWithSelector() external  {
        // call elementaryParamSelector function 
        (bool success1, bytes memory data1) = address(this).call(abi.encodeWithSelector(bytes4(keccak256("elementaryParamSelector(uint256,bool)")), 1, 0));
    }

}


/**
Solidity try-catch

    In Solidity, try-catch only can be used by 'external' function or in constractor.
        try externalContract.f() returns(returnType val){
            // seccess run ...
        } catch {
            // fail run ...
        }

    externalContract.f() is other contract's function
**/
contract OnlyEven{


    constructor(uint a){
        require(a != 0, "invalid number");
        assert(a != 1);
    }

    function onlyEven(uint256 b) external pure returns(bool success){
        // revert when odd be inputed
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}

// call another contract and try-catch some error
contract TryCatch{
        // success event
    event SuccessEvent();

    // fail event
    event CatchEvent(string message);
    event CatchByte(bytes data);

    OnlyEven even;
    constructor(){
        even = new OnlyEven(2);
    }

    // test call function fail 
    function execute(uint amount) external returns (bool success){
        try even.onlyEven(amount) returns(bool _success){
            // emit when success
            emit SuccessEvent();
            return _success;
        }catch Error(string memory reason){
            // emit when fail
            emit CatchEvent(reason);
        }
    }

    // test new contract 
    function executeNew(uint a) external returns(bool success){
        try new OnlyEven(a) returns(OnlyEven _even){
            // call success
            emit SuccessEvent();
            success = _even.onlyEven(a);
        }catch Error(string memory reason){
            // catch fail revert() and require()
            emit CatchEvent(reason);
        }catch (bytes memory reason){
            // catch fail assert()
            emit CatchByte(reason);
        }
    }
}




