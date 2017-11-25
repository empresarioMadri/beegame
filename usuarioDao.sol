pragma solidity ^0.4.18;
contract UsuarioDao {

    uint internal numeroUsuarios;
    address[] indiceUsuarios;
    address llamador;

    function UsuarioDao(address _llamador) public {
        llamador = _llamador;
    }

    function getNumeroUsuarios() public view returns(uint) {
        return numeroUsuarios;
    }

    function setNumeroUsuarios(uint numero) public {
        numeroUsuarios = numero;
    }

    function getIndiceUsuarios(uint index) public view {
        return indiceUsuarios[index];
    }

    function setIndiceUsuarios(address usuario) public {
        indiceUsuarios.push(usuario);
    }
}