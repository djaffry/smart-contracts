pragma solidity ^0.4.0;

import "./BeerBar.sol";

contract SongVotingBar is BeerBar {

	bytes32[] public titles;
	mapping(bytes32 => uint) public votings;
	bool public votingOpen;

	event VotingOpened();
    event VotingClosed();

    modifier votingIsOpen() {
    	require(votingOpen == true);
    	_;
    }

    modifier votingIsClosed() {
    	require(votingOpen == false);
		_;
    }

	string public constant ROLE_DJ = "dj";

	function openVoting() external opened votingIsClosed onlyRole(ROLE_DJ) {
		votingOpen = true;

		emit VotingOpened();
	}

	function closeVoting() external votingIsOpen onlyRole(ROLE_DJ) {
		// delete titles;
		// delete all mapping entries (set to 0);
		votingOpen = false;
		emit VotingClosed();
	}

	function getVotingStatus() external view returns(bool) {
		return votingOpen;
	}

	function voteSong(bytes32 _title) external payable opened votingIsOpen {
		//buyToken() but is external declared
		// require(beerPrice > 0);
		require(msg.value > 0);
    	uint256 amount = msg.value.div(beerPrice);
    	require(beerTokenContract.balanceOf(address(this)) >= amount);
    	beerTokenContract.transfer(msg.sender, amount);

		if (votings[_title] == 0) {
			titles.push(_title);
		}
		votings[_title] = votings[_title].add(msg.value);
	}

	function chooseSong() external opened onlyRole(ROLE_DJ) view returns(bytes32) { 
		uint max = 0;
		uint count = 0;
		uint pos = 0;
		for (uint i = 0; i < titles.length; i++) {
			count = votings[titles[i]];
			if (count > max) {
				max = count;
				pos = i;
			}
		}
		return titles[pos];
	}

	function playSong(bytes32 _title) external opened onlyRole(ROLE_DJ) returns(bool) {
		votings[_title] = 0;
		//play song offchain
		return true;
	}
	
}