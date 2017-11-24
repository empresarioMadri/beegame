pragma solidity ^0.4.18;

library TiposCompartidos {
    enum TipoPremio {none,free,x2,x3,x5, surprise }

    enum EstadoMensaje{pendiente,aprobado,rechazado}

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
        TipoPremio tipo;
        bool premio;
    }

    struct Mensaje {
        address creador;
        string apodo;
        uint256 fechaCreacion;
        string mensaje;
        TiposCompartidos.EstadoMensaje estado;
        string motivo;
    }

    struct Premio {
        address premiado;
        uint256 fechaCreacion;
        uint polenes;
    }
    
}