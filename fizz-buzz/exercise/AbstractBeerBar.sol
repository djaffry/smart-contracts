pragma solidity ^0.4.0;

// use RBAC for role-based access control
import "./zeppelin-solidity/contracts/ownership/rbac/RBAC.sol"; // alte Version, heißt nun RBACWithAdmin
import "./ERC223/ERC223Receiver.sol";
import "./BeerToken.sol";

contract AbstractBeerBar is RBAC, ERC223Receiver {
  
    // customer _from has ordered _amount beer
    event BeerOrdered(address indexed _from, uint256 _amount);
    // customer _from has canceled _amount beer
    event BeerCanceled(address indexed _from, uint256 _amount);
    // new beer tokens (together with beer) have been supplied to the bar
    event BeerSupplied(address indexed _from, uint256 _amount);

    event BarOpened();
    event BarClosed();

    // Bar keepers have to be set by the bar owner using adminAddRole from RBAC
    // The role of the bar owner is modeled with ROLE_ADMIN (defined in RBAC),
    // which initially is the deployer of bar contract
    string public constant ROLE_BARKEEPER = "barkeeper";

    // * The bar uses its own tokens as local currency.
    //   Connect the bar contract with the token contract.
    // * This can only be done by the bar owner.
    BeerToken internal beerTokenContract;
    function setBeerTokenContractAddress(address _address) external
        onlyAdmin
    {
        // Note that the owner of the beer token contract may not be the same
        // as the bar contract owner. This may be a security issue ...
        beerTokenContract = BeerToken(_address);
    }
    
    // show which beer is served
    function beerTokenContractAddress() external view returns(address);

    // * The bar has opening hours during which beer can be ordered and served.
    // * The bar is opened and closed by bar keepers.
    // * When the bar closes, the tokens of all pending orders are returned
    //   to the customers. (Optional; requires extra data structure
    //   to be able to iterate over orders.)
    function openBar() external;
    function closeBar() external;
    function barIsOpen() external view returns (bool);

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

    // * Beer that has been ordered will be served by bar keepers
    // * Beer can  only be served while the bar is open
    function serveBeer(address customer, uint amount) external;

    // * Orders that haven't yet been processed may be canceled by the
    //   customer, who will get back the tokens.
    // * This triggers the event BeerCanceled
    // * Orders can be canceled at any time
    function cancelOrder(uint amount) external;

    // * Get pending orders for customer
    function pendingBeer(address _addr) external view returns (uint256);

    // * Beer price can only be changed by bar owner when the bar is closed
    function setBeerPrice(uint256 _price) external;
    function getBeerPrice() external view returns(uint256);
    
    // * Customers may buy tokens for Ether
    // * If the supplied Ether is not divisible by the beer price
    //   the rest is kept as a tip. The caller (like the web interface)
    //   can check that the value is a multiple of the beer price.
    function buyToken() external payable;

    // * _amount (in Wei) of the Ether stored in the contract is transferred to
    //   _receiver, provided _amount does not exceed the balance of the contract.
    // * Only the bar owner may do this.
    function payout(address _receiver, uint256 _amount) external;
    
}
