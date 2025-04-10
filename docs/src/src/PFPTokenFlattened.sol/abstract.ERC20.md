# ERC20
[Git Source](https://github.com/KBryan/PFP3eInteractive/blob/9ca4333e3a12a1ceff0ce5cf0bec5d44ba67c678/src/PFPTokenFlattened.sol)

**Inherits:**
[Context](/src/PurposeRewardsFlattened.sol/abstract.Context.md), [IERC20](/src/PurposeRewardsFlattened.sol/interface.IERC20.md), [IERC20Metadata](/src/PFPTokenFlattened.sol/interface.IERC20Metadata.md), [IERC20Errors](/src/PFPTokenFlattened.sol/interface.IERC20Errors.md)

*Implementation of the {IERC20} interface.
This implementation is agnostic to the way tokens are created. This means
that a supply mechanism has to be added in a derived contract using {_mint}.
TIP: For a detailed writeup see our guide
https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
to implement supply mechanisms].
The default value of {decimals} is 18. To change this, you should override
this function so it returns a different value.
We have followed general OpenZeppelin Contracts guidelines: functions revert
instead returning `false` on failure. This behavior is nonetheless
conventional and does not conflict with the expectations of ERC-20
applications.*


## State Variables
### _balances

```solidity
mapping(address account => uint256) private _balances;
```


### _allowances

```solidity
mapping(address account => mapping(address spender => uint256)) private _allowances;
```


### _totalSupply

```solidity
uint256 private _totalSupply;
```


### _name

```solidity
string private _name;
```


### _symbol

```solidity
string private _symbol;
```


## Functions
### constructor

*Sets the values for [name](/src/PFPTokenFlattened.sol/abstract.ERC20.md#name) and {symbol}.
All two of these values are immutable: they can only be set once during
construction.*


```solidity
constructor(string memory name_, string memory symbol_);
```

### name

*Returns the name of the token.*


```solidity
function name() public view virtual returns (string memory);
```

### symbol

*Returns the symbol of the token, usually a shorter version of the
name.*


```solidity
function symbol() public view virtual returns (string memory);
```

### decimals

*Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).
Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the default value returned by this function, unless
it's overridden.
NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
[IERC20-balanceOf](/lib/forge-std/test/StdCheats.t.sol/contract.BarERC1155.md#balanceof) and {IERC20-transfer}.*


```solidity
function decimals() public view virtual returns (uint8);
```

### totalSupply

*See [IERC20-totalSupply](/lib/forge-std/test/StdCheats.t.sol/contract.BarERC1155.md#totalsupply).*


```solidity
function totalSupply() public view virtual returns (uint256);
```

### balanceOf

*See [IERC20-balanceOf](/lib/forge-std/test/StdCheats.t.sol/contract.BarERC1155.md#balanceof).*


```solidity
function balanceOf(address account) public view virtual returns (uint256);
```

### transfer

*See [IERC20-transfer](/lib/forge-std/src/mocks/MockERC20.sol/contract.MockERC20.md#transfer).
Requirements:
- `to` cannot be the zero address.
- the caller must have a balance of at least `value`.*


```solidity
function transfer(address to, uint256 value) public virtual returns (bool);
```

### allowance

*See [IERC20-allowance](/lib/forge-std/src/mocks/MockERC20.sol/contract.MockERC20.md#allowance).*


```solidity
function allowance(address owner, address spender) public view virtual returns (uint256);
```

### approve

*See [IERC20-approve](/lib/forge-std/src/mocks/MockERC20.sol/contract.MockERC20.md#approve).
NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
`transferFrom`. This is semantically equivalent to an infinite approval.
Requirements:
- `spender` cannot be the zero address.*


```solidity
function approve(address spender, uint256 value) public virtual returns (bool);
```

### transferFrom

*See [IERC20-transferFrom](/lib/forge-std/src/mocks/MockERC20.sol/contract.MockERC20.md#transferfrom).
Skips emitting an {Approval} event indicating an allowance update. This is not
required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].
NOTE: Does not update the allowance if the current allowance
is the maximum `uint256`.
Requirements:
- `from` and `to` cannot be the zero address.
- `from` must have a balance of at least `value`.
- the caller must have allowance for ``from``'s tokens of at least
`value`.*


```solidity
function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
```

### _transfer

*Moves a `value` amount of tokens from `from` to `to`.
This internal function is equivalent to [transfer](/src/PFPTokenFlattened.sol/abstract.ERC20.md#transfer), and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.
Emits a {Transfer} event.
NOTE: This function is not virtual, {_update} should be overridden instead.*


```solidity
function _transfer(address from, address to, uint256 value) internal;
```

### _update

*Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
(or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
this function.
Emits a {Transfer} event.*


```solidity
function _update(address from, address to, uint256 value) internal virtual;
```

### _mint

*Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
Relies on the `_update` mechanism
Emits a {Transfer} event with `from` set to the zero address.
NOTE: This function is not virtual, {_update} should be overridden instead.*


```solidity
function _mint(address account, uint256 value) internal;
```

### _burn

*Destroys a `value` amount of tokens from `account`, lowering the total supply.
Relies on the `_update` mechanism.
Emits a {Transfer} event with `to` set to the zero address.
NOTE: This function is not virtual, {_update} should be overridden instead*


```solidity
function _burn(address account, uint256 value) internal;
```

### _approve

*Sets `value` as the allowance of `spender` over the `owner` s tokens.
This internal function is equivalent to `approve`, and can be used to
e.g. set automatic allowances for certain subsystems, etc.
Emits an {Approval} event.
Requirements:
- `owner` cannot be the zero address.
- `spender` cannot be the zero address.
Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.*


```solidity
function _approve(address owner, address spender, uint256 value) internal;
```

### _approve

*Variant of [_approve](/src/PFPTokenFlattened.sol/abstract.ERC20.md#_approve) with an optional flag to enable or disable the {Approval} event.
By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
`_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
`Approval` event during `transferFrom` operations.
Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
true using the following override:
```solidity
function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
super._approve(owner, spender, value, true);
}
```
Requirements are the same as {_approve}.*


```solidity
function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual;
```

### _spendAllowance

*Updates `owner` s allowance for `spender` based on spent `value`.
Does not update the allowance value in case of infinite allowance.
Revert if not enough allowance is available.
Does not emit an {Approval} event.*


```solidity
function _spendAllowance(address owner, address spender, uint256 value) internal virtual;
```

