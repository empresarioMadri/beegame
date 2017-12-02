pragma solidity ^0.4.18;

contract Called {

    address public caller;

    function Called() public {
        caller = msg.sender;
    }

    modifier onlyCaller {
        require(msg.sender == caller);
        _;
    }

    function transferCallership(address newCaller) public onlyCaller {
        caller = newCaller;
    }
}