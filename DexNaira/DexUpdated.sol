// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Naira is ReentrancyGuard, Ownable {
    mapping (address => uint) public balances;
    uint256 public totalDestroyed;
    uint256 public totalIssued;
    uint256 public lockedUntil;

    event nairaIssued(uint256 _amount, address _to);
    event nairaDestroyed(uint256 _amount, address _from);
    event nairaTransferred(uint _amount, address from, address _to, bytes32 _description);

    constructor() public {
        lockedUntil = block.timestamp + 1 minutes;
    }

    //function for smart contract to receive money and lock withdrawal or transfer time
    function receiveMoney() public payable onlyOwner {
        totalIssued += msg.value;
    }

    //CBN issues Naira to users 
    function issueNaira(address _to, uint256 _amount) public payable onlyOwner {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        balances[_to] += _amount;
        totalIssued += _amount;
        emit nairaIssued(msg.value, msg.sender);
    }

    //CBN destroys issued naira 
    function destroyNaira(address _from, uint256 _amount) public onlyOwner {
        require(_from != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        require(balances[_from] >= _amount, "Not enough balance");
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
