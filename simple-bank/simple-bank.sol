
/*  Create new Smart contract: SimpleBank
 *  And send money between accounts 
 */

pragma solidity ^0.4.22;
contract SimpleBank {
	mapping (address => uint256) private contract_balance;

	constructor() public{

	}
	
	modifier senderHasAmount(uint256 amount) {
	   require(contract_balance[msg.sender] >= amount);
	   _;
	}
	
	function deposit() external payable {
	    contract_balance[msg.sender] = contract_balance[msg.sender] + msg.value;
	}
	
	function withdraw(address target, uint256 amount) external senderHasAmount(amount) {
	    contract_balance[msg.sender] = contract_balance[msg.sender] - amount;
        target.transfer(amount);
	}
	
	function transfer(address target, uint256 amount) external senderHasAmount(amount) {
	    contract_balance[msg.sender] = contract_balance[msg.sender] - amount;
        contract_balance[target] = contract_balance[target] + amount;
	}
	
	function balance() external view returns(uint256) {
	    return contract_balance[msg.sender];
	}
}


/* Solidity http! -> Run -> Web3Provider (localblockchain open in geth) -> 

simplebank.deposit.sendTransaction({from: eth.accounts[0], value: 200})


// balance script:

function balance(){
	console.log("your accounts:")
	for (var i = 0; i < eth.accounts.length; i++) {
		console.log("   > " + eth.accounts[i] + ': ' + web3.fromWei(eth.getBalance(eth.accounts[i]), "ether"))
	}
}

balance();

simplebank.address = 0x0a5762c0d1b0c99f0b587557fb1be37623949b65
personal.unlockAccount(eth.accounts[0])
simplebank.balance({from: eth.accounts[1]})

// read address of LVA simplebank with
addresses.getPublic(2)

*/
