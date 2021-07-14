type account is [@layout:comb] record [
  balance          : nat; 
  allowances       : map(address, nat); 
]

type token_metadata_info is record [
  token_id         : nat; 
  token_info       : map(string, bytes); 
]

type token_storage is [@layout:comb] record [
  total_supply     : nat; 
  ledger           : big_map(address, account); 
#if MINT_ENABLED
  minters          : set(address); 
#endif
#if SET_MINTER_ENABLED
  admin            : address; 
#endif
  metadata         : big_map(string, bytes); 
  token_metadata   : big_map(nat, token_metadata_info); 
]

type return is list(operation) * token_storage

type transfer_params is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type balance_params is michelson_pair(address, "owner", contract(nat), "")
type allowance_params is michelson_pair(michelson_pair(address, "owner", address, "spender"), "", contract(nat), "")
type total_supply_params is unit * contract(nat)
type mint_params is list(address * nat)
type burn_params is address * nat
type set_minter_params is address * bool

type token_action is
| Transfer of transfer_params
| Approve of michelson_pair(address, "spender", nat, "value")
| GetBalance of balance_params
| GetAllowance of allowance_params
| GetTotalSupply of total_supply_params
#if MINT_ENABLED
| Mint of mint_params
#endif
#if BURN_ENABLED
| Burn of burn_params
#endif
#if SET_MINTER_ENABLED
| SetMinter of set_minter_params
#endif

[@inline] const zero_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address);
