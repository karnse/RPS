// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import './CommitReveal.sol';

contract RPS is CommitReveal{
    struct Player {
        uint choice; // 0 - Rock, 1 - Paper , 2 - Scissors, 3 - undefined
        address addr;
    }
    uint public numPlayer = 0;
    uint public numReveal = 0;
    uint public reward = 0;
    mapping (uint => Player) public player;
    mapping (address => uint) public playerIndex;
    uint public numInput = 0;

    function addPlayer() public payable {
        require(numPlayer < 2);
        require(msg.value == 1 ether);
        reward += msg.value;
        player[numPlayer].addr = msg.sender;
        playerIndex[msg.sender] = numPlayer;
        player[numPlayer].choice = 3;
        numPlayer++;
    }

    function input(bytes32 hashedChoice) public  {
        require(numPlayer == 2);
        require(msg.sender == player[playerIndex[msg.sender]].addr);
        commit(hashedChoice);
        numInput++;
    }

    function choiceHash(uint choice,uint password) public view returns(bytes32) {
        require(choice == 0 || choice == 1 || choice == 2,"invalid choice");
        return getSaltedHash(bytes32(choice), bytes32(password));
    }
    function revealsChoice(uint choice,uint password) public{
        require(numInput == 2);
        require(choice == 0 || choice == 1 || choice == 2,"invalid choice");
        revealAnswer(bytes32(choice),bytes32(password));
        player[playerIndex[msg.sender]].choice = choice;
        numReveal++;
        if (numReveal == 2) {
            _checkWinnerAndPay();
        }
    }
    function _checkWinnerAndPay() private {
        uint p0Choice = player[0].choice;
        uint p1Choice = player[1].choice;
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        if ((p0Choice + 1) % 3 == p1Choice) {
            // to pay player[1]
            account1.transfer(reward);
        }
        else if ((p1Choice + 1) % 3 == p0Choice) {
            // to pay player[0]
            account0.transfer(reward);    
        }
        else {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
    }
}
