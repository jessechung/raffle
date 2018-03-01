pragma solidity ^0.4.17;

contract raffle {

    address public owner;
    uint public raffleEnd;
    uint public itemPrice;
    address[] public arr;
    mapping(address => uint) rafflePot;

    //initializes raffle and sets owner and time left in the raffle
    function raffle(
        uint _raffleEnd,
        uint _itemPrice
    ) public 
    {
        owner = msg.sender;
        //sets the end time for raffle
        raffleEnd = now + _raffleEnd;
        itemPrice = _itemPrice;
    }

    //enter the raffle
    function enterRaffle() public payable {
        //requires the money sent to be equal to the itemPrice
        require(msg.value == itemPrice);
        //requires the raffle to still be ongoing
        require(now <= raffleEnd);

        rafflePot[msg.sender] += msg.value;
    }

    
    
}