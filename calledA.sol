pragma solidity ^0.4.18;

contract CalledA {

    address[] public callers;

    function CalledA() public {
        callers.push(msg.sender);
    }

    modifier onlyCallers {
        bool encontrado = false;
        for (uint i = 0; i < callers.length && !encontrado; i++) {
            if (callers[i] == msg.sender) {
                encontrado = true;
            }
        }
        require(encontrado);
        _;
    }

    function transferCallership(address newCaller,uint index) public onlyCallers {
        callers[index] = newCaller;
    }

    function deleteCaller(uint index) public onlyCallers {
        delete callers[index];
    }

    function addCaller(address caller) public onlyCallers {
        callers.push(caller);
    }
}