pragma solidity ^0.4.17;

contract Raffle {

    address public owner;
    address public oracle;

    uint public seed;

    uint public raffleEnd;
    uint public itemPrice;

    //address[] public addressList;
    mapping(address => uint) rafflePot;
    
    struct addressStruct {
        address addr;
        bool initialize;
    } 

    addressStruct[] public addressList;
    mapping(address => addressStruct) addressIn;

    //initializes raffle and sets owner and time left in the raffle
    function Raffle(
        uint _raffleEnd,
        uint _itemPrice
    ) public 
    {
        owner = msg.sender;
        //sets the end time for raffle
        raffleEnd = now + _raffleEnd;
        itemPrice = _itemPrice;
        seed = 0;
    }

    //enter the raffle
    function enterRaffle() public payable {
        //requires the money sent to be equal to the itemPrice
        require(msg.value == itemPrice);
        //requires the raffle to still be ongoing
        require(now <= raffleEnd);
        require(msg.sender != owner);
        require(msg.sender != oracle);

        //addressList.push(msg.sender);

        addressStruct memory entered = addressStruct(msg.sender, true);
        addressList.push(entered);
        rafflePot[msg.sender] += msg.value;
        addressIn[msg.sender] = entered;
    }

    //returns money if they have it
    function returnMoney() public returns (bool){
        
        require(now >= raffleEnd);

        uint money = rafflePot[msg.sender];
        if (money > 0) {
            rafflePot[msg.sender] = 0;
            if (!msg.sender.send(money)) {
                // No need to call throw here, just reset the amount owing
                rafflePot[msg.sender] = money;
                return false;
            }
        }
        return true;

    }
    
    //owner sets an oracle
    function chooseOracle(address _oracle) public returns (address) {
        // check new oracle is not owner and message sent by owner
        require(msg.sender == owner);
        require(addressIn[msg.sender].initialize == false);

        if (owner != _oracle) {
            oracle = _oracle;
            return _oracle;
        }
        return 0;
    }
    //oracle provides a seed
    function oracleSeed(uint _seed) public {
        require(msg.sender == oracle);
        seed = _seed;
    }

    //generates a randomNumber 
    function rand(uint min, uint max) private returns (uint){
        return uint(sha3(seed))%(min+max)-min;
    }

    //chooses winner based on oracle seed
    function chooseWinner() public {
        require(now >= raffleEnd);
        require(seed != 0);
        require(msg.sender == owner);

        uint winnerIndex = rand(0, addressList.length-1);
        uint winningAmount = rafflePot[addressList[winnerIndex].addr];

        rafflePot[addressList[winnerIndex].addr] = 0;

        owner.transfer(winningAmount);
        
    }

    
    
}