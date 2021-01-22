#! /bin/bash

solcjs *.sol --bin --abi \
	ERC223/* zeppelin-solidity/contracts/math/*.sol \
	zeppelin-solidity/contracts/ownership/Ownable.sol \
	zeppelin-solidity/contracts/token/ERC20/*.sol \
	zeppelin-solidity/contracts/lifecycle/*.sol \
	zeppelin-solidity/contracts/ownership/rbac/*.sol \
	-o out