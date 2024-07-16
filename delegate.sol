
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract B{
    uint public num;
     address  public sender;
     uint public value;


     function setvars(uint _value) public payable {
        num=_value;
        sender=msg.sender;
        value=msg.value;
     }


}


contract A{

uint public num;
address public  sender;
 uint public value;

 function setVarsDelegateCall(address _contract, uint num) public payable {
    (bool success, bytes memory data)= _contract.delegatecall(
        abi.encodeWithSignature("setvars(uint256)", num)
    );
 }

 function setVarCall(address _contract,uint nums) public  payable {
    (bool success,bytes memory data)= _contract.call(
        abi.encodeWithSignature("setVars(uint256)", nums)
    );
 }
}

We have two contracts, Contract A & B and an EOA.

EOA Address = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

Contract A Address = 0x7b96aF9Bd211cBf6BA5b0dd53aa61Dc5806b6AcE

Contract B Address = 0x3328358128832A260C76A4141e19E2A943CD4B6D

We’re going to call the 2 functions in Contract A, setVarsDelegateCall & setVarsCall.

We will pass in the parameters Contract B Address, a uint of 12 and a Wei value of 1000000000000000000 (1 ETH).


Delegate Call

An EOA address calls Contract A’s setVarsDelegateCall with Contract B’s address, uint 12 and value 1000000000000000000 Wei. This in turn makes a delegatecall to Contract B’s setVars(uint256) function with uint 12.

The delegatecall executes the setVars(uint256) code from Contract B but updates Contract A’s storage. The execution has the same storage, msg.sender & msg.value as its parent call setVarsDelegateCall.

The values are set in Contract A’s storage, 12 for num, 0x5b38…c4 for sender (EOA Address) & 1000000000000000000 for value. Despite setVars(uint256) being called by Contract A with no value when we check msg.sender & msg.value we get the values from the original setVarsDelegateCall.

After the execution of this function we can check the num, sender & value state items of Contract A & B. We will see that none of the values are initialised in Contract B while all are set in Contract A.



Call

An EOA address calls Contract A’s setVarsCall with Contract B’s address, uint 12 and value 1000000000000000000 Wei. This in turn makes a call to Contract B’s setVars(uint256) function with uint 12.

The standard call executes the setVars(uint256) code from Contract B with no alterations to storage, msg.sender, msg.value.

The values are set in Contract B’s storage, 12 for num, 0x7b96…ce for sender (Contract A Address) & 0 for value. These values correspond with what we expect since setVars(uint256) was called from Contract A and no Wei value was passed into the setVars(uint256) (the 1000000000000000000 Wei was passed into the parent call setVarsCall)

Again after the execution of this function we can check the num, sender & value state items of Contract A & B. We see that the reverse is true this time, none of the values are initialised in Contract A while all are set in Contract B.

Conceptually a “Delegate Call” effectively allows you to copy and paste a function from another contract into your contract. It will be run as if it were executed by your contract and will have access to the same storage, msg.sender & msg.value.

https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-a5f?utm_source=%2Fprofile%2F80455042-noxx&utm_medium=reader2&s=r

Remember a function in a contract maps to some static bytecode that is calculated at compile time.
