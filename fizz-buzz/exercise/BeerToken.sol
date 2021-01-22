pragma solidity ^0.4.18;

import "./ERC223/Mintable223Token.sol";
import "./ERC223/Burnable223Token.sol";

contract BeerToken is Mintable223Token, Burnable223Token {

	string public constant symbol = "Mi";
    string public constant name = "Mi Beer";
    uint8 public constant decimal = 0;
}
