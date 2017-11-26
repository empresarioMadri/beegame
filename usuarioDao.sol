pragma solidity ^0.4.18;

import "./called.sol";

contract UsuarioDao is Called { 

    uint internal numeroUsuarios;
    address[] indiceUsuarios;

    function UsuarioDao() public {
        indiceUsuarios.push(msg.sender);
        numeroUsuarios = 1;
    }

    function getNumeroUsuarios() public view returns(uint) {
        return numeroUsuarios;
    }

    function setNumeroUsuarios(uint numero) public onlyCaller {
        numeroUsuarios = numero;
    }

    function getIndiceUsuarios(uint index) public view returns (address) {
        return indiceUsuarios[index];
    }

    function setIndiceUsuarios(address usuario) public onlyCaller {
        indiceUsuarios.push(usuario);
    }

}