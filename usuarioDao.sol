pragma solidity ^0.4.18;

contract UsuarioDao is Owned {

    uint internal numeroUsuarios;
    address[] indiceUsuarios;

    function UsuarioDao() public {
    }

    function getNumeroUsuarios() public view returns(uint) {
        return numeroUsuarios;
    }

    function setNumeroUsuarios(uint numero) public onlyOwner {
        numeroUsuarios = numero;
    }

    function getIndiceUsuarios(uint index) public view returns (address) {
        return indiceUsuarios[index];
    }

    function setIndiceUsuarios(address usuario) public onlyOwner {
        indiceUsuarios.push(usuario);
    }

}