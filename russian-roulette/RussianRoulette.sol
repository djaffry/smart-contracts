pragma solidity ^0.4.22;
contract RussianRoulette {
 
    mapping(address => uint256) private amounts;
    
    mapping(address => uint256) private wins;
    mapping(address => uint256) private looses;
    mapping(address => uint8) private  lastGameOutcome;
    
    function deposit() public payable {
        amounts[msg.sender] += msg.value;
    }
    
    function spinAndPullTrigger() public returns(string) {
        if(amounts[msg.sender] <= 0) {
            return "make deposit() first!";

        } else {
            if (random() % 6 == 0) {
                amounts[msg.sender] = 0;
                address burnAddr = address(0x0000000000000000000000000000000000000000);
                burnAddr.transfer(amounts[msg.sender]);
                looses[msg.sender] = looses[msg.sender] + 1;
                lastGameOutcome[msg.sender] = 0;
            } else {
                uint256 refund = amounts[msg.sender];
                amounts[msg.sender] = 0;
                msg.sender.transfer(refund);
                wins[msg.sender] = wins[msg.sender] + 1;
                lastGameOutcome[msg.sender] = 1;
            }
        }
    }
    
    function getOutcome() public view returns(string) {
        if (lastGameOutcome[msg.sender] != 0) {
            return "PHEW... LUCKY YOU!";
        } else return "BANG!";
    }
    
    function getStatistic() public pure returns(string) {
        return strConcat("WINS: ", uint256ToString(0), "", "", "");
    }
    
    function getDeposit() public view returns(uint256) {
        return amounts[msg.sender];
    }
    
    function uint256ToString (uint256 n) internal pure returns (string) {
        if (n == 0) return "0";
        uint256 length = lengthOfNumber(n);
        bytes memory bytesString = new bytes(length);
        for (uint256 i = length - 1; n > 0; i--) {
            bytesString[i] = byte((n % 10) + 0x30);
            n /= 10;
        }
       
        return string(bytesString);
   }
   
    function lengthOfNumber(uint256 _number) private pure returns (uint length) {
        length = 1;
        while (_number > 9) {
           length++;
           _number /= 10;
        }
        return length;
    }
   
    function random() internal view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%216 + 1);
    }

    // <ORACLIZE_API>
    /*
    Copyright (c) 2015-2016 Oraclize SRL
    Copyright (c) 2016 Oraclize LTD

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    */
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
}