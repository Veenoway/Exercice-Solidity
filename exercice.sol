
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Router {

    function swapExactTokensForTokens( 
        uint _amountIn, uint _amountOutMin, address[] calldata _path,
        address _to, uint _deadline) external returns(uint[] memory amounts) {
    }   
}

contract MOBL is ERC20 {
  
  constructor() ERC20('MOBL', 'Mobl Token') {
    
    _mint(msg.sender, 5000);
  }
}

contract Swapper is MOBL {

    mapping(bytes32 => address) public whitelistedTokens;
    mapping(address => mapping(bytes32 => uint256)) public accountBalances;
    mapping(address => bool) whiteListedAddress;
    address MOBLAddress;
    address owner;
    uint tokenOwnedByAddress;

    constructor() {
        owner = msg.sender;
    }

    // MODIFIER

    modifier isWhitelisted(address _address) {
        require(whiteListedAddress[_address], "You need to be whitelisted");
        _;
    } 

    modifier isOwner() {
        require(msg.sender == owner, "Caller must be the owner");
        _;
    }

    // ADD ADDRESS TO WHITELIST  

    function addWhiteListeAddress(address _addressToWL) public isOwner {   
        whiteListedAddress[_addressToWL] = true;
    }

    // SHOW WHITELISTED FROM ADDRESS

    function addressWhitelisted(address _addressWL) public view returns(bool) {       
        return whiteListedAddress[_addressWL];
    }

    // WHITELIST THE TOKEN

    function whitelistToken(bytes32 _symbol, address _tokenAddress) public {
        require(msg.sender == owner, 'This function is not public');
        whitelistedTokens[_symbol] = _tokenAddress;
    }

    // GET WHITELISTED TOKEN

    function getWhitelistedTokenAddresses(bytes32 _token) external view returns(address) {
        return whitelistedTokens[_token];
    }

    // SWAP 

    Router router = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Ethereum Uniswap V2
    ERC20 USDC_token = ERC20(0x70cDFb73f78c51BF8a77b36c911d1F8c305d48E6); // USDC TOKEN Ropsten
    ERC20 MOBL_token  = ERC20(MOBLAddress); // MOBL CONTRACT

    function swapUSDCToMOBL(uint _amount) public payable isWhitelisted(msg.sender){
        require(_amount + tokenOwnedByAddress <= 500, "Cant buy more than 500 MOBL");
        require(msg.sender.balance >= _amount, "Insufficent funds");
        USDC_token.transferFrom(msg.sender, address(this), _amount);
        address[] memory path = new address[](2);
        path[0] = address(USDC_token); 
        path[1] = address(MOBL_token);

        USDC_token.approve(address(router), _amount);
        router.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // WITHDRAW FROM CONTRACT TO ADDRESS 

    function withDrawOwner(address _addresstoWithDraw) public isOwner payable{
        payable(msg.sender).transfer(_addresstoWithDraw.balance);
    }
}