pragma solidity ^0.4.18;

import './TiposCompartidos.sol';
import "./calledA.sol";

contract CeldaDao is CalledA {

    uint internal numeroCeldas;
    mapping (uint256 => TiposCompartidos.Celda) internal celdas;
    uint256[] internal indiceCeldas;
    TiposCompartidos.Celda internal celdaTmp;

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

    function setNumeroCeldas(uint numero) public onlyCallers {
        numeroCeldas = numero;
    }

    function getIndiceCeldas(uint indice) public view returns(uint256) {
        if (indiceCeldas.length == 0)
            return 0;
        else
            return indiceCeldas[indice];
    }

    function setIndiceCeldas(uint256 value) public onlyCallers {
        indiceCeldas.push(value);
    }

    function getCeldas1(uint256 id) public view returns(
        address creador, uint polenPositivos, uint polenNegativos, uint256 fechaCreacion,
        uint primeraPosicion, uint segundaPosicion, uint terceraPosicion) 
    {
            TiposCompartidos.Celda memory celda = celdas[id];
            return (celda.creador,celda.polenPositivos,celda.polenNegativos, celda.fechaCreacion,
            celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion);
    }

    function getCeldas2(uint256 id) public view returns(
        uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio)
    {
        TiposCompartidos.Celda memory celda = celdas[id];
        return (celda.cuartaPosicion, celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }
    
    function setCeldas1(address _creador, uint _polenPositivos, uint _polenNegativos, uint _fechaCreacion, 
        uint _primeraPosicion, uint _segundaPosicion, uint _terceraPosicion) public onlyCallers {
            celdaTmp.creador=_creador;
            celdaTmp.polenPositivos = _polenPositivos;
            celdaTmp.polenNegativos = _polenNegativos;
            celdaTmp.fechaCreacion = _fechaCreacion;
            celdaTmp.primeraPosicion = _primeraPosicion;
            celdaTmp.segundaPosicion = _segundaPosicion;
            celdaTmp.terceraPosicion = _terceraPosicion;
        }

    function setCeldas2(uint _cuartaPosicion, uint _quintaPosicion, uint _sextaPosicion, TiposCompartidos.TipoPremio _tipo, bool _premio) public onlyCallers 
    {
        celdaTmp.cuartaPosicion = _cuartaPosicion;
        celdaTmp.quintaPosicion = _quintaPosicion;
        celdaTmp.sextaPosicion = _sextaPosicion;
        celdaTmp.tipo=_tipo;
        celdaTmp.premio=_premio;
        celdas[celdaTmp.fechaCreacion] = celdaTmp;
    }

}