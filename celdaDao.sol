pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';

contract CeldaDao {

    uint internal numeroCeldas;
    mapping (uint256 => TiposCompartidos.Celda) internal celdas;
    uint256[] internal indiceCeldas;
    address internal llamador;
    address internal owner;
    TiposCompartidos.Celda internal celdaTemp;

    function CeldaDao(address _llamador) public {
        llamador = _llamador;
        owner = msg.sender;
    }

    function getNumeroCeldas() public view returns(uint) {
        return numeroCeldas;
    }

    function setNumeroCeldas(uint numero) public onlyLlamador {
        numeroCeldas = numero;
    }

    function getIndiceCeldas(uint indice) public view returns(uint256) {
        return indiceCeldas[indice];
    }

    function setIndiceCeldas(uint256 value) public onlyLlamador {
        indiceCeldas.push(value);
    }

    function getCeldas1(uint256 id) public view returns(
        address creador, uint polenPositivos, uint polenNegativos, 
        uint primeraPosicion, uint segundaPosicion, uint terceraPosicion,
        uint cuartaPosicion) {
        
        TiposCompartidos.Celda memory celda = celdas[id];
        return (celda.creador,celda.polenPositivos,celda.polenNegativos,
        celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion, celda.cuartaPosicion);
    }

    function getCeldas2(uint256 id) public view returns(
        uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio) {
        
        TiposCompartidos.Celda memory celda = celdas[id];
        return (celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }

    function setCeldas1(address _creador, uint _polenPositivos, uint _polenNegativos, uint _fechaCreacion, 
        uint _primeraPosicion, uint _segundaPosicion, uint _terceraPosicion,
        uint _cuartaPosicion) public onlyLlamador {
        celdaTemp.creador = creador;
        celdaTemp.polenPositivos = polenPositivos; 
        celdaTemp.polenNegativos = polenNegativos;
        celdaTemp.fechaCreacion = fechaCreacion;
        celdaTemp.primeraPosicion = primeraPosicion;
        celdaTemp.segundaPosicion = segundaPosicion;
        celdaTemp.terceraPosicion = terceraPosicion;
        celdaTemp.cuartaPosicion = cuartaPosicion;
            
        celdas[_fechaCreacion] = celdaTemp;
    }

    function cambiarLlamador(address _llamador) public onlyOwner {
        llamador = _llamador;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}