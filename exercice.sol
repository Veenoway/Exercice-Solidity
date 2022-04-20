
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
  
  constructor() ERC20('MOBL', 'Mobula Finance') {
    _mint(msg.sender, 5 * 1e10); // 50 B
  }
}

contract Swapper {

    mapping(bytes32 => address) public whitelistedTokens;
    mapping(address => mapping(bytes32 => uint256)) public accountBalances;
    mapping(address => bool) whiteListedAddress;
    address MOBLAddress;
    address owner;
    uint MontantByAddress;

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

    // SWAP USDC TO MOBL

    Router router = Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); // Ethereum Uniswap V2
    ERC20 USDC_token = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC USD Coin
    ERC20 MOBL_token  = ERC20(MOBLAddress); // MOBL Mobula Finance 

    function swapUSDCToMOBL(uint _amount) public payable isWhitelisted(msg.sender){
        require(_amount + MontantByAddress <= 50000, "Cant buy more than 50 000 MOBL");
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