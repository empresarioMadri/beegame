pragma solidity ^0.4.18;

library TiposCompartidos {
    enum TipoPremio {none,free,x2,x3,x5, surprise }

    enum EstadoMensaje{pendiente,aprobado,rechazado}

    struct Celda {
        address creador;
        uint polenPositivos;
        uint polenNegativos;
        uint fechaCreacion;
        uint primeraPosicion;
        uint segundaPosicion;
        uint terceraPosicion;
        uint cuartaPosicion;
        uint quintaPosicion;
        uint sextaPosicion;
        TipoPremio tipo;
        bool premio;
    }

    struct Mensaje {
        address creador;
        string apodo;
        uint fechaCreacion;
        string mensaje;
        TiposCompartidos.EstadoMensaje estado;
        string motivo;
    }

    struct Premio {
        address premiado;
        uint fechaCreacion;
        uint polenes;
    }

    struct Bote {
        address premiado;
        uint fechaCreacion;
        uint polenes;
    }

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToStr(bytes32 _bytes32) public pure returns (string){
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
}