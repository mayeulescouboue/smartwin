// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Lottery {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping(uint => address payable) public lotteryHistory;
    bool public lotteryStarted;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        lotteryStarted = false;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players; 
    }

    function enter() public payable {
        require(lotteryStarted, "La loterie nest pas demarree");
        require(msg.value > .0001 ether, "ETH minimum non atteint");
 
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp, players.length)));
    }

    function pickWinner() public onlyOwner returns (address payable) {
        require(players.length > 0, "Aucun joueur dans la loterie");

        uint index = getRandomNumber() % players.length;
        address payable winner = players[index];
        
        winner.transfer(address(this).balance);
        
        lotteryHistory[lotteryId] = winner;
        lotteryId++;
        
        delete players; 
        
        return winner;
    }

    function startLottery() public onlyOwner {
        require(!lotteryStarted, "La loterie est deja demarree");
        lotteryStarted = true;
    }

    function endLottery() public onlyOwner {
        require(lotteryStarted, "La loterie n'est pas encore demarree");
        lotteryStarted = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut appeler cette fonction");
        _;
    }
}
