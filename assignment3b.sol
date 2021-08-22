pragma solidity ^0.8.0;
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Assign3Token is IERC20{
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _supplyCap;
    
    uint256 private _lastTransactionTime;
    uint256 private _timeForNextTransaction;

    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint public conversion;

    constructor () public {
        name = "Assign3 Token";
        symbol = "Token";
        owner = msg.sender;
        
        conversion = 100; //1 ether equals 100 tokens
        _totalSupply = 1000000;
        
        _supplyCap = 9000000;
        _lastTransactionTime = 0;
        _timeForNextTransaction = 1 minutes;
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] > amount,"Transfer amount exceeds balance");
        require(block.timestamp > _lastTransactionTime + 1 minutes, 'Time bound token requires time before token can be transfered again');
        
        _lastTransactionTime = block.timestamp;
        //decrease the balance of token sender account
        _balances[sender] = _balances[sender] - amount;
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }


    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return _allowances[tokenOwner][spender]; //return allowed amount
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address tokenOwner = msg.sender;
        require(tokenOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    function transferFrom(address tokenOwner, address recipient, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender]; //how much allowed
        require(_allowance > amount, "Transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance - amount;
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner] - amount; 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
    
    function mintTokens() public returns (bool){
        require(_totalSupply<_supplyCap, 'Supply cap reached');
        _totalSupply = _totalSupply+1000000;
        _balances[owner] = _balances[owner]+1000000;
        return true;
    }
    
    function buyTokens(address buyer) payable public{
        require(msg.value> 0 ether, "Ether required to buy the token");
        uint amount = uint(msg.value/1000000000000000000) * conversion;
        require(amount <= _balances[owner], "Not Enough Tokens left.");
        require(block.timestamp > _lastTransactionTime + 1 minutes, 'Time bound token requires time before token can be transfered again');
        
        _lastTransactionTime = block.timestamp;
        
        _balances[owner] = _balances[owner] - amount;
        
        _balances[buyer] = _balances[buyer] + amount;
        emit Transfer(owner, buyer, amount);

    }
    
    
    function adjustPrice(uint256 converionRate) public{
        require(owner == msg.sender, "Owner address mis-matched");
        conversion = converionRate;
        
    }
    
    function etherBalance() public view returns (uint balance){
        require(msg.sender == owner, "Owner address mis-matched");
        return address(this).balance;
    }
    
    function collectEther() public payable{
        require(msg.sender == owner, "Owner address mis-matched");
        payable(msg.sender).transfer(address(this).balance);
 }
    
    fallback() external payable{
        
    }
    

}