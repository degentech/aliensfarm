#include "../modules/CommonSchema.ligo"
#include "../modules/VaultStorageSchema.ligo"
#include "../modules/VaultSchema.ligo"
#include "../modules/VaultMethods.ligo"
#include "../modules/FarmFA12Methods.ligo"

function main(const action : vault_action; const s : vault_storage) : return is
  case action of
  | Default                            -> default(s)
  | Join(params)                  -> join(params.0, params.1, s)
  | Quit(params)                  -> quit(params, s)
  | Earn(params)                  -> earn(params, s)
  | Swap(params)                  -> swap(params, s)
  | Sync(params)                  -> sync(params, s)
  | Fund(params)                  -> fund(params, s)
  | ChangeReferralSystem(params)  -> change_referral_system(params, s)
  | ChangeAdmin(params)           -> change_admin(params, s)
  | Approve(params)               -> approve(params.0, params.1, s)
  | Transfer(params)              -> transfer(params.0, params.1.0, params.1.1, s)
  | GetBalance(params)            -> get_balance(params.0, params.1, s)
  | GetAllowance(params)          -> get_allowance(params.0.0, params.0.1, params.1, s)
  | GetTotalSupply(params)        -> get_total_supply(params.1, s)
  end
