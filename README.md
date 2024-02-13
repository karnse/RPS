# Rock Paper Scissors task
## First task: Protect Front Running Attack with Commit and Reveal

### solution the first task of front running with use commit and reveal

1. inherit RPS with commit-reveal
2. add the hashchoice function to hash the choice of the player by input the choice and the secret
3. modify input function to input the hash of the choice only and commit the hash of choice
4. add the reveal function to reveal the choice of the player by input the choice and the secret
5. and modify exicute _checkWinnerAndPay when numReveals == 2 to check the winner and pay the reward

## Second task: provide time limit for the game

1. add the time limit = 10 minutes
2. add updatedtime  to check the time limit
3. update updatedtime in all the functions that the player can call (input, revealsChoice, addplayer)
4. add time limit function to check the time limit and end the game if the time limit is over to withdraw the reward or punish when another player didn't respond in the time limit

## Third task: update the game to be a RWAPSSF

1. check require choice from 3 to 7
2. modify the checkWinnerAndPay to check the winner and pay the reward


# example of the game
## win lose
player 1: lose
<br/>
player 2: win
![image](https://github.com/karnse/RPS/assets/88821340/11cb274d-92d9-4c25-a701-0a0fbf44709c)

## draw
![image](https://github.com/karnse/RPS/assets/88821340/2a503819-3136-46c7-a9be-0201177372f6)

