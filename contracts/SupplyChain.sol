// Implement the smart contract SupplyChain following the provided instructions.
// Look at the tests in SupplyChain.test.js and run 'truffle test' to be sure that your contract is working properly.
// Only this file (SupplyChain.sol) should be modified, otherwise your assignment submission may be disqualified.

pragma solidity ^0.5.0;

contract SupplyChain {
  address owner;
  // Create a variable named 'itemIdCount' to store the number of items and also be used as reference for the next itemId.
  uint private itemIdCount;

  // Create an enumerated type variable named 'State' to list the possible states of an item (in this order): 'ForSale', 'Sold', 'Shipped' and 'Received'.
  enum State { ForSale, Sold, Shipped, Received }

  // Create a struct named 'Item' containing the following members (in this order): 'name', 'price', 'state', 'seller' and 'buyer'.
  struct Item{
    string name;
    uint id;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  // Create a variable named 'items' to map itemIds to Items.
  mapping (uint256 => Item) public items;
  // Create an event to log all state changes for each item.
  event ForSale(uint id);
  event Sold(uint indexed id);
  event Shipped(uint id);
  event Received(uint id);


  // Create a modifier named 'onlyOwner' where only the contract owner can proceed with the execution.
  modifier onlyOwner(address _address){ require (owner == _address); _;}
  // Create a modifier named 'checkState' where the execution can only proceed if the respective Item of a given itemId is in a specific state.
  modifier paidEnough(uint _price) { require (msg.value >= _price); _;}
  modifier checkState(uint _id){
    if(items[_id].state == State.ForSale) _;
    else if(items[_id].state == State.Sold) _;
    else if(items[_id].state == State.Shipped) _;
    else if(items[_id].state == State.Received) _;
    }

  // Create a modifier named 'checkCaller' where only the buyer or the seller (depends on the function) of an Item can proceed with the execution.
  modifier checkCaller (address _address) { require (msg.sender == _address); _;}
  // Create a modifier named 'checkValue' where the execution can only proceed if the caller sent enough Ether to pay for a specific Item or fee.
  modifier checkValue(uint _id) {
    _;
    uint _price = items[_id].price;
    uint refund = msg.value - _price;
    items[_id].buyer.transfer(refund);
  }

  constructor() public payable {
    owner = msg.sender;
    itemIdCount = 0;
  }

  // Create a function named 'addItem' that allows anyone to add a new Item by paying a fee of 1 finney. Any overpayment amount should be returned to the caller. All struct members should be mandatory except the buyer.
  function addItem(string memory _name, uint _price) public returns(bool){
    emit ForSale(itemIdCount);
    items[itemIdCount] = Item({name: _name, id: itemIdCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    itemIdCount += 1;
    return true;
  }

  // Create a function named 'buyItem' that allows anyone to buy a specific Item by paying its price. The price amount should be transferred to the seller and any overpayment amount should be returned to the buyer.
  function buyItem(uint id) payable public ForSale(id) paidEnough(items[id].price) checkValue(id) {
    items[id].buyer = msg.sender;
    items[id].state = State.Sold;
    uint _value = msg.value;
    items[id].seller.transfer(_value);
    emit Sold(id);
  }
  // Create a function named 'shipItem' that allows the seller of a specific Item to record that it has been shipped.
  function shipItem(uint id) public Sold(id) checkCaller(items[id].seller){
    items[id].state = State.Shipped;
    emit Shipped(id);
  }

  // Create a function named 'receiveItem' that allows the buyer of a specific Item to record that it has been received.
  function receiveItem(uint id) public Shipped(id) checkCaller(items[id].buyer){
    items[id].state = State.Received;
    emit Received(id);
  }

  // Create a function named 'getItem' that allows anyone to get all the information of a specific Item in the same order of the struct Item.
  function getItem(uint _id) public view returns (string memory name, uint id, uint price, uint state, address seller, address buyer) {
    name = items[_id].name;
    id = items[_id].id;
    price = items[_id].price;
    state = uint(items[_id].state);
    seller = items[_id].seller;
    buyer = items[_id].buyer;
    return (name, id, price, state, seller, buyer);
  }

  // Create a function named 'withdrawFunds' that allows the contract owner to withdraw all the available funds.
  function withdrawFunds(uint _id) public {

  }

  function() external{
    revert();
  }
}
