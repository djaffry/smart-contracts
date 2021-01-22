pragma solidity ^0.4.23;

import "./BeerBar.sol";

contract FizzBuzz is BeerBar {

    using SafeMath for uint128;
    using SafeMath for uint256;
    
    mapping(uint256 => GameDetails) games;
    mapping(address => uint256) gameref;
    uint256 gamecounter;
    
    bytes8 fizz = "FIZZ";
    bytes8 buzz = "BUZZ";
    bytes16 fizzbuzz = "FIZZBUZZ";

    uint256 gameToken;

    string public constant ROLE_JURY = "jury";

    struct GameDetails {
        address player1;
        address player2;
        
        uint256 turn;
        
        uint128 commitment;
        uint8 number1;
        uint8 number2;
        bool active;
        bool payedp1;
        bool payedp2;
    }

    event GameRequestEvent(address from, address to);
    event NextTurnEvent(address next, address other);
    event EndGameEvent(address winner, address loser, uint128 commitment);
    event AbortEvent(address player1, address player2);
    event DonationEvent(address donator, uint256 value);

    modifier hasNoGame(address player) {
        require(games[gameref[player]].active == false);
        _;
    }
    
    modifier activeGame(address player) {
        require(games[gameref[player]].active == true);
        _;
    }

    modifier hasPayed(address player) {
        //has to be an active game
        GameDetails memory game = games[gameref[msg.sender]];
        require(game.active == true);
        if (game.player1 == player) {
            require(game.payedp1 == true);
        } else {
            require(game.payedp2 == true);
        }
        _;
    }

    /* Getter */

    function getTurn() view public activeGame(msg.sender) returns (uint256) {
        return games[gameref[msg.sender]].turn;
    }
    
    function getMyTurn() view public activeGame(msg.sender) returns (bool) {
        GameDetails memory game = games[gameref[msg.sender]];
        if (game.turn == 0) {
            return false;
        } else if (game.turn % 2 == 1) {
            if (game.player1 == msg.sender) {
                return true;
            } else {
                return false;
            }
        } else {
             if (game.player2 == msg.sender) {
                return true;
            } else {
                return false;
            }
        }
    }

    function getOtherPlayer() view public activeGame(msg.sender) returns (address) {
        GameDetails memory game = games[gameref[msg.sender]];
        if (game.player1 == msg.sender) {
                return game.player2;
        } else {
                return game.player1;
        }
    }

    function getCommitment() view public activeGame(msg.sender) returns (uint128) {
        return games[gameref[msg.sender]].commitment;
    }

    function getNumber1() view public activeGame(msg.sender) returns (uint8) {
        return games[gameref[msg.sender]].number1;
    }


    function getNumber2() view public activeGame(msg.sender) returns (uint8) {
        return games[gameref[msg.sender]].number2;
    }

    function getHaveIPayed() view public activeGame(msg.sender) returns (bool) {
        GameDetails memory game = games[gameref[msg.sender]];
        if (game.player1 == msg.sender) {
                return game.payedp1;
        } else {
                return game.payedp2;
        }
    }

    function getHasOtherPayed() view public activeGame(msg.sender) returns (bool) {
        GameDetails memory game = games[gameref[msg.sender]];
        if (game.player1 == msg.sender) {
                return game.payedp2;
        } else {
                return game.payedp1;
        }
    }

    /* Game Logic */
    
    function newGame(address other, uint128 commitment, uint8 n1) public hasNoGame(msg.sender) hasNoGame(other) {
        require(commitment > 0);
        require(n1 > 1 && n1 <= 32);
        require(msg.sender != other);
        
        gameref[msg.sender] = gamecounter;
        gameref[other] = gamecounter;
        gamecounter++; //overflow overrides oldest games after 2^256 games
        GameDetails storage game = games[gameref[msg.sender]];
        game.player1 = msg.sender;
        game.player2 = other;
        game.turn = 0;
        game.commitment = commitment;
        game.number1 = n1;
        game.number2 = 0;
        game.active = true;
        game.payedp1 = false;
        game.payedp2 = false;


        emit GameRequestEvent(msg.sender, other);
    }
    
    function acceptGame(uint8 n2) public hasPayed(msg.sender) {
        require(n2 > 1 && n2 <= 32);

        games[gameref[msg.sender]].number2 = n2;
        games[gameref[msg.sender]].turn = 1;

        emit NextTurnEvent(games[gameref[msg.sender]].player1, games[gameref[msg.sender]].player2);
    }
    
    function rejectGame() public {
        require(games[gameref[msg.sender]].active == true &&
            games[gameref[msg.sender]].turn == 0);
        abort(msg.sender); 
    }

    function makeMove(bytes32 text) public hasPayed(msg.sender) {
        require(getMyTurn() == true);
        GameDetails storage game = games[gameref[msg.sender]];

        //uint256 overflows to byte32 conversion. do draw() instead.
        if (game.turn >= 10000000000000000000000000000000) {
            abort(msg.sender);
            return;
        }

        bytes32 expected;
        if (game.turn % game.number1 == 0 && game.turn % game.number2 == 0) {
            expected = fizzbuzz;
        } else if (game.turn % game.number1 == 0) {
            expected = fizz;
        } else if (game.turn % game.number2 == 0) {
            expected = buzz;
        } else {
            expected = uintToBytes(game.turn);
        }

        if (expected == text) {
            game.turn = game.turn.add(1);

            if (game.turn % 2 == 1) {
                emit NextTurnEvent(game.player1, game.player2);
            } else {
                emit NextTurnEvent(game.player2, game.player1);
            }
            
        } else { 
            /* msg.sender lost */
            game.active = false;
            if (game.player1 == msg.sender) {
                emit EndGameEvent(game.player2, game.player1, game.commitment);
                require(gameToken >= game.commitment.mul(2));
                gameToken = gameToken.sub(game.commitment.mul(2));
                beerTokenContract.transfer(game.player2, game.commitment.mul(2));
            
            } else {
                emit EndGameEvent(game.player1, game.player2, game.commitment);
                require(gameToken >= game.commitment.mul(2));
                gameToken = gameToken.sub(game.commitment.mul(2));
                beerTokenContract.transfer(game.player1, game.commitment.mul(2));
            }
            unlinkGame(msg.sender);
        }
    }

    function uintToBytes(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }
    
    function abort(address player) internal activeGame(player) {
        GameDetails storage game = games[gameref[player]];

        if (game.payedp1 == true) {
            require(gameToken >= game.commitment);
            gameToken = gameToken.sub(game.commitment);
            beerTokenContract.transfer(game.player1, game.commitment);
        }
        
        if (game.payedp2 == true) {
            require(gameToken >= game.commitment);
            gameToken = gameToken.sub(game.commitment);
            beerTokenContract.transfer(game.player2, game.commitment);
        }
        game.active = false;
        unlinkGame(player);
        emit AbortEvent(game.player1, game.player2);
    }

    function unlinkGame(address player) internal {
        games[gameref[player]].active = false;
        if (games[gameref[player]].player1 == player) {
            delete gameref[games[gameref[player]].player2];
        } else {
            delete gameref[games[gameref[player]].player1];   
        }
        delete games[gameref[player]];
        delete gameref[player];
    }

    function refund(address player) external onlyRole(ROLE_JURY) { 
        abort(player);
    }

    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
        require(msg.sender == address(beerTokenContract));
        if (keccak256(_data) == keccak256("supply")) {
            return supplyBeer(_sender, _value);

        } else if (keccak256(_data) == keccak256("")) {
            return orderBeer(_sender, _value);

        } else if (keccak256(_data) == keccak256("game")) {
            return commitToGame(_sender, _value);
        }
        return false;
    }

    function commitToGame(address _sender, uint256 _value) internal activeGame(_sender) opened returns (bool success) {
        gameToken = gameToken.add(_value);
        GameDetails storage game = games[gameref[_sender]];

        require(game.commitment == _value);
        
        if (game.player1 == _sender) {
            game.payedp1 = true;
        } else {
            game.payedp2 = true;
        }
        return true;
    }

    function donate() external payable {
        require(msg.value > 0);
        emit DonationEvent(msg.sender, msg.value);
    }

    function payoutGame(address _receiver, uint256 _amount) external onlyAdmin {
        require (_amount <= address(this).balance);
        _receiver.transfer(_amount);
    }
}
