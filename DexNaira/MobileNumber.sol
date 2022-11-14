// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PhoneNUmbers{
    address public centralBank;

    struct BankDetails{
        string name;
        bool authorization;
    }

    mapping(address => BankDetails) public banks;
    mapping(uint256 => address[]) public mobileNumbers;

    event bankAdded(address _bank, string _bankName);
    event bankRemoved(address _bank);
    event mobileNumbersAdded(address _bankAddress, uint256 _mobileNumber);
    event removedMobileNumber(uint256 _mobileNumber);

    constructor(){
        centralBank = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == centralBank, "Not CentralBank");
        _;
    }

    //fucntion to register new banks 
    function addBank(address _bank, string memory _bankName) public onlyOwner{
        if(centralBank == msg.sender) {
            banks[_bank] = BankDetails(_bankName, true);
            emit bankAdded(_bank, _bankName);
        }
    }

    //function to remove bank 
    function removeBank(address _bank) public onlyOwner{
        if(centralBank == msg.sender) {
            banks[_bank].authorization = false;
        }
        emit bankRemoved(_bank);
    }

    //function to view bank details 
    function getBankDetails(address _bank) public view returns(string memory bankName, bool authorization){
        return(banks[_bank].name, banks[_bank].authorization);
    }

    //function to add mobile numbers 
    function addMobileNumber(uint256 _mobileNumber) public onlyOwner{
        if(banks[msg.sender].authorization == true) {
            for(uint256 count = 0; count < mobileNumbers[_mobileNumber].length; count++){
                if(mobileNumbers[_mobileNumber][count] == msg.sender){
                    return;
                }
            }
            mobileNumbers[_mobileNumber].push(msg.sender);
        }
        emit mobileNumbersAdded(msg.sender, _mobileNumber);
    }

    function removeMobileNumber(uint256 _mobileNumber) public onlyOwner{
        if(banks[msg.sender].authorization == true){
            for(uint256 count = 0; count < mobileNumbers[_mobileNumber].length; count ++){
                if(mobileNumbers[_mobileNumber][count] == msg.sender) {
                    delete mobileNumbers[_mobileNumber][count];

                    for(uint i = count; i < mobileNumbers[_mobileNumber].length - 1; i++){
                        mobileNumbers[_mobileNumber][i] = mobileNumbers[_mobileNumber][i + 1];
                    }
                    mobileNumbers[_mobileNumber].pop();
                    break;
                }
            }
        }
        emit removedMobileNumber(_mobileNumber);
    }

    function getMobileNumberBanks(uint256 _mobileNumber) public view returns(address[] memory _banks) {
        return mobileNumbers[_mobileNumber];
    }

}
