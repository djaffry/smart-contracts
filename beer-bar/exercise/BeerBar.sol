pragma solidity ^0.4.0;

import "./AbstractBeerBar.sol";
import "./zeppelin-solidity/contracts/math/SafeMath.sol";

contract BeerBar is AbstractBeerBar {

/*
   	// customer _from has ordered _amount beer
    event BeerOrdered(address indexed _from, uint256 _amount);
    // customer _from has canceled _amount beer
    event BeerCanceled(address indexed _from, uint256 _amount);
    // new beer tokens (together with beer) have been supplied to the bar
    event BeerSupplied(address indexed _from, uint256 _amount);

    event BarOpened();
    event BarClosed();
    */	

    using SafeMath for uint256;

    bool public isOpen;
    uint256 public beerPrice;
    mapping(address => uint256) public orders;

    modifier opened() {
    	require(isOpen == true);
    	_;
    }

    modifier closed() {
    	require(isOpen == false);
		_;
    }


    constructor() public {
    	//admin is set automatically (RBAC.sol)
    }
    
    // show which beer is served
    function beerTokenContractAddress() external view returns(address) {
    	return address(beerTokenContract);
    }

    // * The bar has opening hours during which beer can be ordered and served.
    // * The bar is opened and closed by bar keepers.
    // * When the bar closes, the tokens of all pending orders are returned
    //   to the customers. (Optional; requires extra data structure
    //   to be able to iterate over orders.)
    function openBar() external closed onlyRole(ROLE_BARKEEPER) {
    	isOpen = true;
    	emit BarOpened();
    }

    function closeBar() external opened onlyRole(ROLE_BARKEEPER) {
    	isOpen = false;
    	emit BarClosed();
    }
    function barIsOpen() external view returns (bool) {
    	return isOpen;
    }

    // * When new beer is delivered, the token contract owner mints new
    //   tokens and transfers them to the bar contract with the string
    //   "supply" in the data field (since this is not a beer order).
    //   Minting and Transfer have to be triggered by the web interface.
    // * The bar contract emits the event BeerSupplied when receiving
    //   tokens marked as "supply".

    // * Beer is ordered by transferring beer tokens to the bar contract
    //   with the empty data field (standard transfer); 1 token = 1 beer
    // * In addition to the internal bookkeeping, the event
    //   BeerOrdered is triggered to signal that there is work
    // * Beer can only be ordered while the bar is open

    // Both, supply and order, are to be implemented in the tokenFallback,
    // see ERC223Receiver:
    // function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success);

    function tokenFallback(address _sender, address _origin, uint256 _value, bytes _data) public returns (bool success) {
    	require(msg.sender == address(beerTokenContract));
        if (keccak256(_data) == keccak256("supply")) {
    		return supplyBeer(_sender, _origin, _value, _data);

    	} else if (keccak256(_data) == keccak256("")) {
    		return orderBeer(_sender, _origin, _value, _data);
    	}
    	return false;
    }

    function supplyBeer(address _sender, address _origin, uint256 _value, bytes _data) internal returns (bool) {
    	emit BeerSupplied(_sender, _value);
    	return true;
    }

    function orderBeer(address _sender, address _origin, uint256 _value, bytes _data) internal opened returns (bool success) {
		orders[_sender] = orders[_sender].add(_value);
    	emit BeerOrdered(_sender, _value);
    	return true;
    }

    // * Beer that has been ordered will be served by bar keepers
    // * Beer can  only be served while the bar is open
    function serveBeer(address customer, uint amount) external opened onlyRole(ROLE_BARKEEPER) {
    	require(orders[customer] >= amount);
    	orders[customer] = orders[customer].sub(amount);
    }

    // * Orders that haven't yet been processed may be canceled by the
    //   customer, who will get back the tokens.
    // * This triggers the event BeerCanceled
    // * Orders can be canceled at any time
    function cancelOrder(uint amount) external {
    	require(orders[msg.sender] >= amount);
    	emit BeerCanceled(msg.sender, amount);
    }

    // * Get pending orders for customer
    function pendingBeer(address _addr) external view returns (uint256) {
    	return orders[_addr];
    }

    // * Beer price can only be changed by bar owner when the bar is closed
    function setBeerPrice(uint256 _price) external onlyAdmin closed {
    	require(_price > 0);
    	beerPrice = _price;
    }

    function getBeerPrice() external view returns(uint256) {
    	return beerPrice;
    }
    
    // * Customers may buy tokens for Ether
    // * If the supplied Ether is not divisible by the beer price
    //   the rest is kept as a tip. The caller (like the web interface)
    //   can check that the value is a multiple of the beer price.
    function buyToken() external payable {

        // TODO
        // TODO check if token is really spendable
    	// TODO
        require(msg.value > 0);
    	uint256 amount = msg.value / beerPrice;
    	require(beerTokenContract.balanceOf(address(this)) >= amount);
    	beerTokenContract.transfer(msg.sender, amount);
    }

    // * _amount (in Wei) of the Ether stored in the contract is transferred to
    //   _receiver, provided _amount does not exceed the balance of the contract.
    // * Only the bar owner may do this.
    function payout(address _receiver, uint256 _amount) external onlyAdmin {
    	require (_amount <= address(this).balance);
    	msg.sender.transfer(address(this).balance);
    }
    
}
