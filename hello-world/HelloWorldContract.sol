pragma solidity ^0.4.22;
contract HelloWorld {
    string private message;

    //function HelloWorld(string _value) public{ @depricated
    constructor(string _value) public {
        message = _value;
    }

    function setMessage(string _value) public{
        message = _value;
    }
    function viewMessage() public view returns(string){
        return message;
    }
}