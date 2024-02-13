// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import './CommitReveal.sol';

contract RWAPSSF is CommitReveal{
    struct Player {
        uint choice; // 0 - Rock, 1 - Paper , 2 - Scissors, 3 - undefined
        address addr;
    }
    uint public numPlayer = 0;
    uint public numReveal = 0;
    uint public reward = 0;
    uint public limitTime = 10 minutes;
    uint public updatedTimestamp;
    mapping (uint => Player) public player;
    mapping (address => uint) public playerIndex;
    uint public numInput = 0;

    function cleardata() private {
        numInput = 0;
        numPlayer = 0;
        numReveal = 0;
        reward = 0;
    }

    function checkTimeOut() public {
        require(block.timestamp+limitTime < updatedTimestamp,"in time");
        if(numPlayer==1)
        {
            payable(player[0].addr).transfer(reward);
            delete player[0];
            cleardata();
        }
        else if(numPlayer==2 && numInput==0)
        {
            payable(player[0].addr).transfer(reward/2);
            payable(player[1].addr).transfer(reward/2);
            delete player[0];
            delete player[1];
            cleardata();
        }
        else if(numPlayer==2 && numInput==1)
        {
            if(commits[player[1].addr].commit == 0)
            {
                payable(player[0].addr).transfer(reward);
                delete commits[player[0].addr];
                delete player[0];
                delete player[1];
            }
            if(commits[player[0].addr].commit == 0)
            {
                payable(player[1].addr).transfer(reward);
                delete commits[player[1].addr];
                delete player[0];
                delete player[1];
            }
            cleardata();
        }
        else if(numPlayer == 2 && numInput == 2 && numReveal==0)
        {
            payable(player[0].addr).transfer(reward/2);
            payable(player[1].addr).transfer(reward/2);
            delete commits[player[0].addr];
            delete commits[player[1].addr];
            delete player[0];
            delete player[1];
            cleardata();
        }
        else if(numPlayer == 2 && numInput == 2 && numReveal==1)
        {
            if(commits[player[1].addr].revealed)
            {
                payable(player[1].addr).transfer(reward);
            }
            if(commits[player[0].addr].revealed)
            {
                payable(player[0].addr).transfer(reward);
            }
            delete commits[player[0].addr];
            delete commits[player[1].addr];
            delete player[0];
            delete player[1];
            cleardata();
        }
    }

    function addPlayer() public payable {
        require(numPlayer < 2);
        require(msg.value == 1 ether);
        reward += msg.value;
        player[numPlayer].addr = msg.sender;
        playerIndex[msg.sender] = numPlayer;
        player[numPlayer].choice = 3;
        updatedTimestamp = block.timestamp;
        numPlayer++;
    }

    function input(bytes32 hashedChoice) public  {
        require(numPlayer == 2);
        require(msg.sender == player[playerIndex[msg.sender]].addr);
        commit(hashedChoice);
        updatedTimestamp = block.timestamp;
        numInput++;
    }

    function choiceHash(uint choice,uint password) public view returns(bytes32) {
        require(choice < 7);
        return getSaltedHash(bytes32(choice), bytes32(password));
    }
    function revealsChoice(uint choice,uint password) public{
        require(numInput == 2);
        require(choice < 7);
        revealAnswer(bytes32(choice),bytes32(password));
        player[playerIndex[msg.sender]].choice = choice;
        numReveal++;
        if (numReveal == 2) {
            _checkWinnerAndPay();
        }
        updatedTimestamp = block.timestamp;
    }
    function _checkWinnerAndPay() private {
        uint p0Choice = player[0].choice;
        uint p1Choice = player[1].choice;
        address payable account0 = payable(player[0].addr);
        address payable account1 = payable(player[1].addr);
        if ((p0Choice + 1) % 7 == p1Choice || (p0Choice + 2) % 7 == p1Choice || (p0Choice + 3) % 7 == p1Choice) {
            // to pay player[1]
            account1.transfer(reward);
        }
        else if ((p1Choice + 1) % 7 == p0Choice || (p1Choice + 2) % 7 == p0Choice || (p1Choice + 3) % 7 == p0Choice) {
            // to pay player[0]
            account0.transfer(reward);    
        }
        else {
            // to split reward
            account0.transfer(reward / 2);
            account1.transfer(reward / 2);
        }
        delete commits[player[0].addr];
        delete commits[player[1].addr];
        delete player[0];
        delete player[1];
        cleardata();
    }
}
