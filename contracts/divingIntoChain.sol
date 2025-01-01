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
  