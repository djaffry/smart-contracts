
### Smart Contracts Beer Bar ###
David Jaffry

`Geth 1.8.5-unstable`, `solcjs 0.4.23+commit.124ca40d.Emscripten.clang` and `sc.logic.at` has been used to create Fizz Buzz.

### Fizz Buzz ###

Fizz Buzz is the new game of Beer Bar. Haven't heard about it yet? Let me show you what you have missed:
It's derived from an old child game which is often used by software employers to test their eployees coding skills.

## Game Idea ##
Each player is picking a number and shares it to the other. Player 1 starts counting from 1. Player 2 adds one to the turn
counter. And so on. If the turn counter is modulo one of the numbers, you write "FIZZ" for Player 1's number and "BUZZ" for Player 2's instead.
If the turn counter is modulo the two of the numbers, you write "FIZZBUZZ". The player who first makes a mistake loses the game and the
other gets the pot.

## Bullet Points ##

* Mappings are used for mapping a game to 2 addresses. The first one (`games`) has a `gameid` as key and a `GameDetails struct` as value. The second one is 
to map two addresses without too much hassle to a game (`gameref`); 

* There is a new role beyond ROLE_OWNER / ROLE_BARKEEPER, etc. It's ROLE_JURY. If there is any dispute, the Jury can disolve it by aborting the game.
All commitments, which are the deposits for games to prevent aborts or reverts, will be transfered back.

* Modifiers are used to check if a user has an active game, has no active game or has payed his commmitment.

* You can buy tokens with ether or you can donate some ether. Furthermore the owner can receive the ether from the contract. If you do so, a `DonationEvent` get's fired.

* Mi Beer Tokens are used to play the game. Only those are accepted. If you win a game, you get the pot of tokens. If you lose, you lose the token you deposited.

* SafeMath is used when needed. `gamecounter` does not use SafeMath so it can overflow and start anew. It is not feasable to say that more than 2^256 games are 
played and active at once at Fizz Buzz.

* The Beerbar interface has been extended with a FizzBuzz Jury section. There you can find our trusted jury. Partypeople got an extended interface and now can play
FizzBuzz inside the Bar! The UI automatically reloads the game stats on a change in the game. You can also manually reload using the button.

* There are deposits to make before playing a game to prevent aborts and reverts. You cannot abort if both players havae accepeted the game.

You can find the address for Fizz Buzz Bar on `private 100` and the Beer Token on `private 101` or down below.

## Game Steps ##

1. `Player 1` selects their `Player 2` and how much the `commitment` should be and the `number` they want to get their multiple replaced by "FIZZ". The number has to
be between `1 < x <= 32`. A `Game Request Event` gets fired. The game starts. But: You can only start a new Game when both players have no game running yet!

2. `Player 1` commits to the game and deposits their `Beer Token` using `Pay Commitment`. The Bar has to be opened for that, you have to have a game running and the commitment
and the Beer Token deposit has to be exact the same value.

2. `Player 2` sees the Request and sees in their UI that they have been challenged by `Player 1`. If they don't want to play, they can `Reject Fizz Buzz Game` (Back to `1.`). 
You can only reject a game if the game has not had a turn yet. Or they can pay the commitment using the `Pay Commitment` Button which also `Player 1` has to use. Same rules 
apply for using `Pay Commitment`.

3. `Player 2` has to think of a nummber between `1 < x <= 32` which they want their multiple get replaced by "BUZZ" and `Accept Fizz Buzz Game`. A `NextTurnEvent` get's fired.

4. Now the actual game starts. `Player 1` starts with `1` and presses `Make Move`. Now `Player 2` has to enter `2` or either `FIZZ`/`BUZZ` or `FIZZBUZZ`. And so on.
On the beginning of every round a `NextTurnEvent` gets fired. The game ends when one of the two players makes a mistake. The pot goes to the winning Player and an 
`EndGameEvent` gets fired.

A Jury can intersept the game if there is any dispute and resulting the game in a draw. If so, an `AbortEvent` get's fired.


### Compiling ###

You can find a compile-script at the exercise subfolder called `compile.sh`.
It will compile all necessary files in an `out` folder.
```
solcjs *.sol --bin --abi \
	ERC223/* zeppelin-solidity/contracts/math/*.sol \
	zeppelin-solidity/contracts/ownership/Ownable.sol \
	zeppelin-solidity/contracts/token/ERC20/*.sol \
	zeppelin-solidity/contracts/lifecycle/*.sol \
	zeppelin-solidity/contracts/ownership/rbac/*.sol \
	-o out
```
Take the necessary files for deploying from there.


### Deploying ###

## Token ##
```
> var beerTokenAbi = [...]
undefined
> var beerTokenContract = web3.eth.contract(beerTokenAbi);
undefined
> var beerTokenBinary = "0x" + ...;
undefined
> var beerTokenInstance = beerTokenContract.new({from: eth.accounts[0], data: beerTokenBinary, gas: 50000000});
undefined
> beerTokenInstance.address
"0x80d35edad97a7f9306e8a4eecfd43b13ea40df84"
```

After deploy, mint some tokens:
```
> beerTokenInstance.mint.sendTransaction(eth.accounts[0], 1000000000, {from: eth.accounts[0]});
```


## Fizz Buzz Bar ##

```
> var fizzBuzzAbi = [...];
undefined
> var fizzBuzzContract = web3.eth.contract(fizzBuzzAbi);
undefined
> var fizzBuzzBinary = "0x" + ...;
undefined
> var fizzBuzzInstance = fizzBuzzContract.new({from: eth.accounts[0], data: fizzBuzzBinary, gas: 50000000});
undefined
> fizzBuzzInstance.address
"0x69348f0d8bfb662b1d1fc443cd7ca311b619bbdf"
```

## Loading existing Bar ##

```
> var bar_address = "0x" + example_address;
undefined
> var fizzBuzzAbi = [...];
undefined
> var fizzBuzzContract = web3.eth.contract(fizzBuzzAbi);
undefined
> var fizzBuzzInstance = fizzBuzzContract.at(bar_address);
undefined
> fizzBuzzInstance.address
"0x" + example_address
```


### Issues ###

I had a issue deploying my first full prototype of FizzBuzz, since it exceeded the contract size limit (.bin had more than 84kB).
I got this error when deploying it with `geth`:
```
Error: oversized data
    at web3.js:3143:20
    at web3.js:6347:15
    at web3.js:5081:36
    at web3.js:3021:24
    at <anonymous>:1:24
```
So I googled and found this: https://ethereum.stackexchange.com/questions/46541/is-there-a-maximum-number-of-public-functions-in-a-contract
I had to strip it from a few Features (History of played games, Jury functions) and build a more space efficient data structure in order to deploy it. 
Also my first idea was to replace the words "FIZZ" and "BUZZ" by words which could have been chosen by the players. I also had to remove this Feature.

Working with strings/bytes32 is a pain in solidity. :'( You really get to appreciate more High Level Languages.

At first I wanted to implement the game Nine Men's Morris. I started coding a UI in React but I am glad that I changed the project:
Nine Men's Morris would have taken me too long to finish in just 3 weeks.
Surely I would have a much greater problem with the contract size there. I would probably have to build a cluster of contracts which are all connected
and communicate with each other. This could have made the game unplayable since you had to wait for a lot of transactions to finish and would have cost
a lot more to play than a game of FizzBuzz.
