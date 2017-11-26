pragma solidity ^0.4.18;

import './TiposCompartidos.sol';
import "./called.sol";

contract BoteDao is Called {

    uint internal numeroBotes;
    mapping (uint256 => TiposCompartidos.Bote) botes;
    uint256[] indiceBotes;

    function BoteDao() public {
    }

    function getNumeroBotes() public view returns(uint) {
        return numeroBotes;
    }

    function setNumeroBotes(uint numero) public onlyCaller {
        numeroBotes = numero;
    }

    function getIndiceBotes(uint indice) public view returns(uint256) {
        return indiceBotes[indice];
    }

    function setIndiceBotes(uint256 value) public onlyCaller {
        indiceBotes.push(value);
    }

    function getBotes(uint256 id) public view returns(
        address creador,uint256 fechaCreacion,uint polenes) {
        TiposCompartidos.Bote memory bote = botes[id];
        return (bote.premiado,bote.fechaCreacion,bote.polenes);
    }

    function setBotes(address creador,uint256 _fechaCreacion,uint _polenes) public onlyCaller {
        TiposCompartidos.Bote memory bote = TiposCompartidos.Bote({
            premiado:creador,
            fechaCreacion:_fechaCreacion,
            polenes:_polenes
        });
        botes[_fechaCreacion] = bote;
    }

}