#define UPDATE_REWARDS_ENABLED

#include "../modules/CommonSchema.ligo"
#include "../modules/StakingStorageSchema.ligo"
#include "../modules/StakingSchema.ligo"
#include "../modules/StakingMethods.ligo"
#include "../modules/FarmFA12Methods.ligo"

function main(const action : staking_action; const s : staking_storage) : return is
  case action of
  | Join(params)                  -> join(params.0, params.1, s)
  | Quit(params)                  -> quit(params.0, params.1, s)
  | Earn(params)                  -> earn(params.0, params.1, s)
  | EarnCallback(params)          -> earn_callback(params, s)
  | EarnAndJoinCallback(params)   -> earn_and_join_callback(params, s)
  | ChangeReferralSystem(params)  -> change_referral_system(params, s)
  | ChangeRPSAndCoeff(params)     -> change_rps_and_coefficient(params, s)
  | ChangeAdmin(params)           -> change_admin(params, s)
  
  | Approve(params)               -> approve(params.0, params.1, s)
  | Transfer(params)              -> transfer(params.0, params.1.0, params.1.1, s)
  | GetBalance(params)            -> get_balance(params.0, params.1, s)
  | GetAllowance(params)          -> get_allowance(params.0.0, params.0.1, params.1, s)
  | GetTotalSupply(params)        -> get_total_supply(params.1, s)
  end
