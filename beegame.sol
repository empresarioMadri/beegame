pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/tiposCompartidos.sol';
import 'https://github.com/empresarioMadri/beegame/token.sol';

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}



contract BeeGame is owned {
    
    
    address token;

    function BeeGame (
        uint256 initialSupply,
        uint256 newSellPrice,
        uint256 newBuyPrice) public {
        token = new Token(this,initialSuply,newSellPrice,newBuyPrice);
        
    }

    function getToken() public view returns(address) {
        return token;
    }

    function cambiarLlamador()public onlyOwner {
        Token contrato = Token(token);

    }

    

    
}