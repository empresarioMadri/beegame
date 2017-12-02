pragma solidity ^0.4.18;

import './calledA.sol';
import './TiposCompartidos.sol';
import './boteService.sol';
import './mensajeService.sol';
import './celdaService.sol';
import './tokenService.sol';
import './usuarioService.sol';

contract BeeGame is CalledA {

    address internal tokenService;
    TokenService internal tokenServiceImpl;

    address internal celdaService; 
    CeldaService internal celdaServiceImpl;

    address internal mensajeService;
    MensajeService internal mensajeServiceImpl;

    address internal boteService;
    BoteService internal boteServiceImpl;

    address internal usuarioService;
    UsuarioService internal usuarioServiceImpl;
    
    address internal owner;
    
    function BeeGame () public {
        owner = msg.sender;
    }
    
    function getOwner() public view returns(address){
        return owner;
    }
    
    function setMensajeService(address _mensajeService)public onlyCallers{
        mensajeService = _mensajeService;
        mensajeServiceImpl = MensajeService(mensajeService);
    }
    
    function getMensajeService() public view returns (address){
        return mensajeService;
    }
    
    function getBalanceEth(address sender) public view returns(uint){
        return sender.balance * 1 ether;
    }
    
    function setTokenService(address _tokenService)public onlyCallers{
        tokenService = _tokenService;
        tokenServiceImpl = TokenService(tokenService);
    }
    
    function getTokenService() public view returns (address){
        return tokenService;
    }
    
    function setUsuarioService(address _usuarioService)public onlyCallers{
        usuarioService = _usuarioService;
        usuarioServiceImpl = UsuarioService(usuarioService);
    }
    
    function getUsuarioService() public view returns (address){
        return usuarioService;
    }
    
    function setBoteService(address _boteService)public onlyCallers{
        boteService = _boteService;
        boteServiceImpl = BoteService(boteService);
    }
    
    function getBoteService() public view returns (address){
        return boteService;
    }
    
    function setCeldaService(address _celdaService)public onlyCallers{
        celdaService = _celdaService;
        celdaServiceImpl = CeldaService(celdaService);
    }
    
    function getCeldaService() public view returns (address){
        return celdaService;
    }
    
    function buy() public payable {
        tokenServiceImpl.buy(msg.value,msg.sender);
    }

    
    function getBote() public view returns(uint) {
        return tokenServiceImpl.getBote();
    }
    
    function cobrarImpuesto(uint _fechaTax,uint ganador) public onlyCallers {
        tokenServiceImpl.cobrarImpuesto(_fechaTax,ganador);
    }
    
    function crearCelda(uint _polenes, uint256 _fechaCreacion, uint posicion, uint _celdaPadre, uint _celdaAbuelo, TiposCompartidos.TipoPremio tipo) public {
        celdaServiceImpl.setCreador(msg.sender);
        celdaServiceImpl.crearCelda(_polenes,_fechaCreacion,posicion,_celdaPadre,_celdaAbuelo,tipo);
    }
    
    
    function getBoteIndex(uint index) public view returns (address premiado, uint polenes, uint256 fechaCreacion){
        return boteServiceImpl.getBoteIndex(index);
    }
    
    
    function getCelda1(uint index) public view returns (address creador, uint polenPositivos, uint polenNegativos, uint256 fechaCreacion,
                                            uint primeraPosicion, uint segundaPosicion, uint terceraPosicion) {
        return celdaServiceImpl.getCelda1(index);
    }

    function getCelda2(uint index) public view returns (uint cuartaPosicion, uint quintaPosicion, uint sextaPosicion, TiposCompartidos.TipoPremio tipo, bool premio) {
        return celdaServiceImpl.getCelda2(index);
    }
    
    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    function getMensaje(uint index) public view returns(address creador,uint fechaCreacion,string  _mensaje,string  apodo, TiposCompartidos.EstadoMensaje estado, string  motivo){
        TiposCompartidos.Mensaje memory mensaje;
        (mensaje.creador,mensaje.fechaCreacion,mensaje.apodo,mensaje.mensaje,mensaje.estado,mensaje.motivo) = mensajeServiceImpl.getMensaje(index);
        return (mensaje.creador,mensaje.fechaCreacion,bytes32ToStr(mensaje.apodo),bytes32ToStr(mensaje.mensaje),mensaje.estado,bytes32ToStr(mensaje.motivo));
    }
    
    function insertarMensaje(uint256 _fechaCreacion, bytes32  _apodo,bytes32  _mensaje) public {
        mensajeServiceImpl.insertarMensaje(msg.sender,_fechaCreacion,_apodo,_mensaje);
    }
    
    function aprobarMensaje(uint256 _fechaCreacion,TiposCompartidos.EstadoMensaje _estado,bytes32  _motivo) public onlyCallers {
        mensajeServiceImpl.aprobarMensaje(_fechaCreacion,_estado,_motivo);
    }
    
    function getBalance(address addr) public view returns(uint) {
		return tokenServiceImpl.getBalance(addr);
	}

    function getFechaTax() public view returns(uint) {
        return tokenServiceImpl.getFechaTax();
    }

    function getNumeroCeldas() public view returns(uint) {
        return celdaServiceImpl.getNumeroCeldas();
    }

    function getNumeroUsuarios() public view returns(uint) {
        return usuarioServiceImpl.getNumeroUsuarios();
    }

    function getNumeroBotes() public view returns(uint) {
        return boteServiceImpl.getNumeroBotes();
    }

    function getNumeroMensajes() public view returns(uint) {
        return mensajeServiceImpl.getNumeroMensajes();
    }

    function getRevenue(uint amount, address sender) public onlyCallers {
        sender.transfer(amount);
    }
    
    function sell(uint amount) public {
        tokenServiceImpl.sell(amount);
    }

    function setFechaTax(uint _fechaTax) public onlyCallers {
        tokenServiceImpl.setFechaTax(_fechaTax);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyCallers {
        tokenServiceImpl.setPrices(newSellPrice,newBuyPrice);
    }
    
    function transfer(address _to, uint _value) public {
        tokenServiceImpl._transfer(msg.sender, _to, _value);
        usuarioServiceImpl.incluirUsuario(_to);
    }

    
}