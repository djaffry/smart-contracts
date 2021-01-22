
### Smart Contracts Beer Bar ###
David Jaffry

`Geth 1.8.5-unstable`, `solcjs 0.4.23+commit.124ca40d.Emscripten.clang` and `sc.logic.at` has been used to solve this exercise.
I discussed this exercise with Benjamin Krenn.

My last Beer Bar instance:
```
http://localhost:8000/?contract=0x11dfa901b9cdb36dda4fc520ae42ecd524c883f1&invite=0x0531916af0e202b28827d9afbdc141420f23b7cd,0x12eb3d46d3dbe71ad8deb9518f3cef6b4876f49c,0x6501fe5194f2718e1bfe4aa1897d2bd125330f0b
```


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
"0xcb8f96cc40117854a7256a44062f32ab7e9c38b4"
```

After deploy, mint some tokens:
```
> beerTokenInstance.mint.sendTransaction(eth.accounts[0], 1000000000, {from: eth.accounts[0]});
"0xa0bba81691e99467b9df1fe18df208c8d7e9e92da6bef627fd15a195f8232b58"
```


## Bar ##

```
> var songVotingAbi = [...];
undefined
> var songVotingContract = web3.eth.contract(songVotingAbi);
undefined
> var songVotingBinary = "0x" + ...;
undefined
> var songVotingInstance = songVotingContract.new({from: eth.accounts[0], data: songVotingBinary, gas: 50000000});
undefined
> songVotingInstance.address
"0x11dfa901b9cdb36dda4fc520ae42ecd524c883f1"
```

## Loading existing Bar ##

```
> var bar_address = "0x" + example_address;
undefined
> var songVotingAbi = [...];
undefined
> var songVotingContract = web3.eth.contract(songVotingAbi);
undefined
> var songVotingInstance = songVotingContract.at(bar_address);
undefined
> songVotingInstance.address
"0x" + example_address
```


### Issues ###

Getting my head into this stuff was kind of heavy but the workshops helped a lot! Thank you so much for explaining so well :)
I had some issues with deploying and gas limits. I often used the wrong files to deploy since before writing this Readme, everything was a huge mess. 
At the gas limits problem, using the result of the `gasEstimation()` function helped. I added some extra gas for just in case.
I also forgot to check what token to accept. Adding that `require` in the `tokenFallback()` function did the job.
Had some minor jquery issues as well but that resolved quickly.
