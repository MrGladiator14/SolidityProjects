//SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.6.0;

contract wallet{
    address public owner;
    bool public pause;
    constructor() public{
        owner = msg.sender;
    }
    struct payment{
        uint amt;
        uint timestamp;
    }
    struct balance{
        uint totbalance;
        uint numpay;
        mapping(uint => payment) payments;
    }

    modifier onlyOwner(){
        require( msg.sender == owner);
        _;
    }

    modifier whileNotPaused(){
        require( pause == false,"SmartContract is paused");
        _;
    }
    event sentMoney(address indexed add1, uint amt1);
    event recMoney(address indexed add2, uint amt2);

    function change(bool ch) public onlyOwner{
        pause = ch;
    }

    mapping(address => balance) public balance_record;
    function sendmoney() public whileNotPaused payable{
        balance_record[msg.sender].totbalance +=msg.value;
        balance_record[msg.sender].numpay +=1;
        payment memory pay = payment(msg.value,now);
        balance_record[msg.sender].payments[balance_record[msg.sender].numpay] = pay;
        emit sentMoney(msg.sender,msg.value);
    }
    function getbalance() public view whileNotPaused returns(uint){
        return balance_record[msg.sender].totbalance;

    }
    function convert(uint amtInWei) public pure returns(uint){
        return amtInWei/1 ether;
    }
    function withdraw(uint d_amt) public whileNotPaused {
        require(balance_record[msg.sender].totbalance >= d_amt, "no sufficient balance");
        balance_record[msg.sender].totbalance -= d_amt;
        msg.sender.transfer(d_amt);
        emit recMoney(msg.sender,d_amt);
    }
    function destroy(address payable ender) public onlyOwner{
        selfdestruct(ender);
    }
}