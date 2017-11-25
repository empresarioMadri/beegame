pragma solidity ^0.4.18;

import 'https://github.com/empresarioMadri/beegame/TiposCompartidos.sol';

contract CeldaDao {

    enum TipoPremio {none,free,x2,x3,x5, surprise }

    struct Celda {
        address creador;
        uint polenPositivos;
        uint polenNegativos;
        uint256 fechaCreacion;
        uint primeraPosicion;
        uint segundaPosicion;
        uint terceraPosicion;
        uint cuartaPosicion;
        uint quintaPosicion;
        uint sextaPosicion;
        TiposCompartidos.TipoPremio tipo;
        bool premio;
    }

    uint internal numeroCeldas;
    mapping (uint256 => Celda) internal celdas;
    uint256[] internal indiceCeldas;
    address internal llamador;
    address internal owner;

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

    function getCeldas(uint256 id) public view returns(
        address creador, uint polenPositivos, uint polenNegativos, uint fechaCreacion, 
        uint primeraPosicion, uint segundaPosicion, uint terceraPosicion,
        uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio) {
        
        Celda memory celda = celdas[id];
        return (celda.creador,celda.polenPositivos,celda.polenNegativos,celda.fechaCreacion,
        celda.primeraPosicion, celda.segundaPosicion, celda.terceraPosicion, celda.cuartaPosicion, 
        celda.quintaPosicion, celda.sextaPosicion, celda.tipo, celda.premio);
    }

    function getCeldasO(uint256 id) public view returns(Celda) {
        Celda memory celda = celdas[id];
        return celda;
    }

    function setCeldas(address _creador, uint _polenPositivos, uint _polenNegativos, uint _fechaCreacion, 
        uint _primeraPosicion, uint _segundaPosicion, uint _terceraPosicion,
        uint _cuartaPosicion, uint _quintaPosicion, uint _sextaPosicion, TiposCompartidos.TipoPremio _tipo, bool _premio) public onlyLlamador {
        Celda memory celda = Celda({
            creador:msg.sender,
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
    }

    function setCeldasO(uint _fechaCreacion, 
        Celda _celda) public onlyLlamador {
        celdas[_fechaCreacion] = _celda;
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