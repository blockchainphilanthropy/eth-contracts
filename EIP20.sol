pragma solidity ^0.4.20;


contract EIP20MinimumInterface {
  /**
  * @dev total amount of tokens, automatic public getter function created
  */
  uint256 public totalSupply;
  
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value); 
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);  
}

contract TokenEIP20 is EIP20MinimumInterface {
  uint256 constant private MAX_UINT256 = 2**256 - 1;
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
 
  uint256 public totalSupply;
  string  public name;
  string  public symbol;
  uint8   public decimals = 18;

  /**
   * Constructor function
   *
   * Initializes contract with initial supply tokens to the creator of the contract
   */
  function TokenEIP20(
      uint256 initialSupply,
      string tokenName,
      string tokenSymbol
  ) public {
      totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
      balances[msg.sender] = totalSupply;                     // Give the creator all initial tokens
      name = tokenName;                                       // Set the name for display purposes
      symbol = tokenSymbol;                                   // Set the symbol for display purposes
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /** 
  *@notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  * @param _from The address of the sender
  * @param _to The address of the recipient
  * @param _value The amount of token to be transferred
  * @return Whether the transfer was successful or not
  */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    uint256 allowance = allowed[_from][msg.sender];
    require(balances[_from] >= _value && allowance >= _value);
    balances[_to] += _value;
    balances[_from] -= _value;
    if (allowance < MAX_UINT256) {
        allowed[_from][msg.sender] -= _value;
    }
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  /**
  * @notice allows _spender to withdraw from your account multiple times, up to the _value amount
  * @param _spender The address of the account able to transfer the tokens
  * @param _value The amount of tokens to be approved for transfer
  * @return True if the approval was successful
  */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
  * @dev This function makes it easy to read the `allowed[]` map
  * @param _owner The address of the account that owns the token
  * @param _spender The address of the account able to transfer the tokens
  * @return Amount of remaining tokens of _owner that _spender is allowed to spend
  */
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  } 
}
