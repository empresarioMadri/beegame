pragma solidity ^0.4.18;

import './TiposCompartidos.sol';
import './owned.sol';

contract CeldaDao is Owned {

    uint internal numeroCeldas;
    mapping (uint256 => TiposCompartidos.Celda) internal celdas;
    uint256[] internal indiceCeldas;

    function CeldaDao() public {
        TiposCompartidos.Celda memory celda = TiposCompartidos.Celda({
            creador:msg.sender,
            polenPositivos : 0, 
            polenNegativos : 3,
            fechaCreacion: 1509302402021,
            primeraPosicion : 0,
            segundaPosicion : 0,
            terceraPosicion : 0,
            cuartaPosicion : 0,
            quintaPosicion : 0,
            sextaPosicion : 0,
            tipo:TiposCompartidos.TipoPremio.none,
            premio:false
        });
        celdas[1509302402021] = celda;
        indiceCeldas.push(1509302402021);
        numeroCeldas = TiposCompartidos.safeAdd(numeroCeldas,1);
    }

    function getNumeroCeldas() public view returns(uint) {
        return numeroCeldas;
    }

    function setNumeroCeldas(uint numero) public onlyOwner {
        numeroCeldas = numero;
    }

    function getIndiceCeldas(uint indice) public view returns(uint256) {
        if (indiceCeldas.length == 0)
            return 0;
        else
            return indiceCeldas[indice];
    }

    function setIndiceCeldas(uint256 value) public onlyOwner {
        indiceCeldas.push(value);
    }

    function getCeldas1(uint256 id) public view returns(
        address creador, uint polenPositivos, uint polenNegativos, 
        uint primeraPosicion, uint segundaPosicion, uint terceraPosicion,
        uint cuartaPosicion) 
    {
            TiposCompartidos.Celda memory celda = celdas[id];
            return (celda.creador,celda.polenPositivos,celda.polenNegativos,
            celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion, celda.cuartaPosicion);
    }

    function getCeldas2(uint256 id) public view returns(
        uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio)
    {
        TiposCompartidos.Celda memory celda = celdas[id];
        return (celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }

    function setCeldas(address _creador, uint _polenPositivos, uint _polenNegativos, uint _fechaCreacion, 
        uint _primeraPosicion, uint _segundaPosicion, uint _terceraPosicion,
        uint _cuartaPosicion, uint _quintaPosicion, uint _sextaPosicion, TiposCompartidos.TipoPremio _tipo, bool _premio) public onlyOwner 
    {
        TiposCompartidos.Celda memory celda = TiposCompartidos.Celda({
            creador:_creador,
            polenPositivos : _polenPositivos, 
            polenNegativos : _polenNegativos,
            fechaCreacion: _fechaCreacion,
            primeraPosicion : _primeraPosicion,
            segundaPosicion : _segundaPosicion,
            terceraPosicion : _terceraPosicion,
            cuartaPosicion : _cuartaPosicion,
            quintaPosicion : _quintaPosicion,
            sextaPosicion : _sextaPosicion,
            tipo:_tipo,
            premio:_premio
        });
        celdas[_fechaCreacion] = celda;
        indiceCeldas.push(_fechaCreacion);
        numeroCeldas = TiposCompartidos.safeAdd(numeroCeldas,1);
    }

}