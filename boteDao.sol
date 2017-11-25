pragma solidity ^0.4.18;


contract BoteDao {

    uint internal numeroBotes;
    mapping (uint256 => Bote) botes;
    uint256[] indiceBotes;
    address llamador;

    function BoteDao(
        address _llamador
    ) public {
        llamador = _llamador;
    }

    function getNumeroBotes() public view returns(uint) {
        return numeroBotes;
    }

    function setNumeroBotes(uint numero) public onlyLlamador {
        numeroBotes = numero;
    }

    function getIndiceBotes(uint indice) public view returns(uint256) {
        return indiceBotes[indice];
    }

    function setIndiceBotes(uint256 value) public onlyLlamador {
        indiceBotes.push(value);
    }

    function getBotes(uint256 id) public view returns(
        address creador,uint256 fechaCreacion,uint polenes) {
        Bote memory bote = botes[id];
        return (bote.premiado,bote.fechaCreacion,bote.polenes);
    }

    function getBotesO(uint256 id) public view returns(
        TiposCompartidos.Bote) {
        Bote memory bote = botes[id];
        return bote;
    }

    function setBotes(address creador,uint256 _fechaCreacion,uint _polenes) public onlyLlamador {
        Bote memory bote = Bote({
            premiado:msg.sender,
            fechaCreacion:_fechaCreacion,
            polenes:_polenes
        });
        botes[_fechaCreacion] = bote;
    }

    function cambiarLlamador(address _llamador) public onlyLlamador {
        llamador = _llamador;
    }

    modifier onlyLlamador {
        require(msg.sender == llamador);
        _;
    }

}