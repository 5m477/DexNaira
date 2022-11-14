// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
We are assuming that the central bank deploys the smart contract.
We have methods to issue, transfer, and destroy Naira. These methods are
self-explanatory. The transfer method also has a description that can
contain information such as the purpose of the transaction or the receiving customer details.
We have methods to retrieve the balance of an account, and the total Naira
ever issued and destroyed.

*/
//smart contracts for digitalizing fiat currency
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //USE XXXXX

contract Naira is ReentrancyGuard {
    address public centralBank;

    mapping (address => uint) public balances;
    uint256 public totalDestroyed;
    uint256 public totalIssued;
    uint256 public lockedUntil;

    event nairaIssued(uint256 _amount, address _to);
    event nairaDestroyed(uint256 _amount, address _from);
    event nairaTransferred(uint _amount, address from, address _to, bytes32 _description);

    constructor(){
        centralBank = msg.sender;
        lockedUntil = block.timestamp + 1 minutes;
    }

    modifier onlyOwner(){
        require (msg.sender == centralBank, "not centralBank");
        _;
    }

    //function for smart contract to receive money and lock withdrawal or transfer time
    function receiveMoney() public payable {
        totalIssued += msg.value;
    }

    //CBN issues Naira to users 
    function issueNaira(uint256 _amount, address _to) public payable onlyOwner {
        balances[_to] += _amount;
        totalIssued += _amount;
        emit nairaIssued(msg.value, msg.sender);
    }

    //CBN destroys issued naira 
    function destroyNaira(uint256 _amount, address _from) public onlyOwner nonReentrant{
       balances[_from] -= _amount;
       totalDestroyed += _amount;
       emit nairaDestroyed(_amount, _from);
    }


    // Function to transfer money from balances
    function transferNaira(uint256 _amount, address payable _to, bytes32 _description) public nonReentrant {
        require(lockedUntil < block.timestamp, "balanceLocked");
        if( balances[msg.sender] >= _amount){
            balances[_to] += _amount;
        }
        emit nairaTransferred(_amount, msg.sender, _to, _description);
    }

    function getBalance(address _account) external view returns(uint256) {
        return balances[_account];
    }

    function getTotal() external view returns(uint256 _totalDestroyed, uint256 _totalIssued) {
        return(totalDestroyed, totalIssued);
    }
}


