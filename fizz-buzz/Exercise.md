TU Wien's Virtual Beer Bar
==========================

For this assignment, we combine the most favorite hobby of students -
going out and drinking some beer - with the second favorite pastime -
coding.

After this exercise, you'll know how to deliver (or, in this case, mint)
beer and run your own bar. But don't worry, you don't have to get your
hands dirty - everything will run in the safe environment of a
decentralized app.

So let's get started with the smart contract!

Task 1: BeerToken
-----------------

For starters, you'll make your very own token.  And - in contrast to
many ICOs - it even has an important utility: Your users will be able
to exchange this BeerToken for beer later on.

Your Token has to fulfill the following requirements:
- 1 beer token is equivalent to 1 glass of beer. It is not divisible.
- New beer tokens can be minted on demand by the owner of the contract 
  (think of a beer delivery to the bar. The same amount of beer tokens have to be minted and sent to the bar).
- Beer tokens can be burned (as real beer is served to the customers
  and therefore "destroyed")
- In the past, many tokens got lost because they were sent to contracts
  that didn't support the receiving of tokens. Beer is valuable, so 
  make sure this can't happen by accident.

Choose a token standard that fully supports these requirements, and use 
it for your token.

> Remember: These tokens will be compatible with most wallets (because 
> they comply with the ERC20 standard which is used by those wallets)
> If you want to, you can connect MyEtherWallet to our blockchain,
> and use this interface to manage your tokens - and transfer them
> to other accounts.

Task 2: BeerBar
---------------
Now to the fun part: We get to spend those tokens!

An abstract contract AbstractBeerBar is already provided. This contract 
allows bar owners to run their bar using their own beer token. It lays out 
the basic functionality as follows:

Roles:
- For role modeling, we use the RBAC contract of OpenZeppelin. The ROLE_ADMIN 
  is set to be the bar owner when the contract is deployed.
- In addition, the role 'barkeeper' is defined in this contract. Its addresses
  are set via the web interface.

> Remember: You can generate as many Ethereum accounts as you like.
> In the CLI, this is possible with `personal.newAccount("logic")`.
  
Organisational tasks:  
- The bar owner has to set the beer price.
- The barkeepers open and close the bar. 
- The bar owner can transfer part of the bar's ether to a specified address.
  
Beer tokens: 
- The bar owner specifies which type of beer token the bar is going to accept.
- Beer tokens can be sent to the bar, i.e. the contract is a receiver of
  ERC223 tokens.
- The contract only accepts your specified beer token, and no other type of 
token sent to it.
- When beer is delivered to the bar, an equal amount of beer tokens has to be
  sent to the bar marked "supply". 
- Customers can buy the bar's beer token for ether.

Beer orders:
- When a customer sends an amount of tokens to the bar it means an order 
  of the same amount of glasses of beer. This can be done during opening hours.
- During opening hours, barkeepers check the order (to make sure the guest is 
  not already too drunk, or underage - this process happens offline/offchain). 
  When barkeepers decide to accept the order, they serve (deliver) the beer to 
  the customer. If the order is declined, the barkeeper ignores it.
- Customers can check their open/pending orders of beer.
- Customers can cancel their orders before an order is accepted. This  
  allows them to get their tokens back (e.g. if their order is declined or
  they no longer want to have the beer)

Task 3: SongVotingBar
---------------
The days where dreadful music in bars gets played is now over -
customers can vote which songs get added to the playlist!

DJs:
- The bar needs DJs for playing music.
- DJs start the voting (during opening hours).
- DJs end the voting (before or at closing time).
- DJs play the next song according to the voting (songs get played offline/offchain). 

Voting:
- While the voting period is open, customers push their favorite song in or up the 
playlist by sending ether to the bar together with the title of their song.
- For this voting, customers receive beer tokens. The number of tokens is equivalent 
to the amount of ether divided by the beer price. Any remainder is kept as tip.

Selection of the next song played:
- Feel free to define how this is done - you have to consider the votes, though. 
- Furthermore, you have to decide, which parts of this 
selection you like to implement in the web interface and which parts you provide in the contract.

Task 4: web3.js
---------------
A simple webinterface in Javascript is provided that uses web3.js to communicate 
with the BeerBar contract.
Your job is to extend it, so it also works with your SongVotingBar.
You will notice that we deliberately did not specify the API for getting
the current vote list - feel free to implement that to your liking.

Task 5: Profit!
---------------
You are now a proud bar owner, sit back, relax, and enjoy a nice cold BeerToken!

Upload your source code to TUWEL, and include a short README file which describes
how you solved the exercise and which issues you faced.

For grading this exercise, we will automatically test your implementation.
For this, publish the address of your BeerToken at slot ´11´, and your
bar at slot ´12´ of your private address book
(`addresses.setPrivate.sendTransaction(11, "0x...", {from: eth.accounts[0]})`).
Also, make us - the person at ´addresses.getPublic(3)´ to an owner (admin) of
the bar.
We promise, we won't mismanage it...
