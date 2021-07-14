#include "../modules/PaulSchema.ligo"
#include "../modules/FA12Methods.ligo"
#include "../modules/MintableMethods.ligo"

function main(const action : token_action; const s : token_storage) : return is
  case action of
  | Transfer(params)         -> transfer(params.0, params.1.0, params.1.1, s)
  | Approve(params)          -> approve(params.0, params.1, s)
  | GetBalance(params)       -> get_balance(params.0, params.1, s)
  | GetAllowance(params)     -> get_allowance(params.0.0, params.0.1, params.1, s)
  | GetTotalSupply(params)   -> get_total_supply(params.1, s)
  | Mint(params)             -> mint(params, s)
  | Burn(params)             -> burn(params.0, params.1, s)
  | SetMinter(params)        -> set_minter(params.0, params.1, s)
  end
