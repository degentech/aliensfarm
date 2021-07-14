#include "../modules/CommonSchema.ligo"
#include "../modules/StakingStorageSchema.ligo"
#include "../modules/FarmingStorageSchema.ligo"
#include "../modules/VaultStorageSchema.ligo"
#include "../modules/ControllerSchema.ligo"
#include "../modules/ControllerMethods.ligo"

function main(const action : controller_action; const s : controller_storage) : controller_return is
  case action of
  | DeployStaking(params)                       -> deploy_staking(params, s)
  | DeployFarming(params)                       -> deploy_farming(params, s)
  | DeployVault(params)                         -> deploy_vault(params, s)
  | ChangeReferralSystem(params)                -> change_referral_system(params, s)
  | ChangeFarmAdmin(params)                     -> change_farm_admin(params, s)
  | ChangeRPSAndCoefficient(params)             -> change_rps_and_coefficient(params, s)
  | FundVaultDevReserves(params)                -> fund_vault_dev_reserves(params.0, params.1, s)
  | ChangeAdmin(params)                         -> change_admin(params, s)
  | RegisterVault(params)                       -> register_vault(params, s)
  | BurnPauls(params)                           -> burn_pauls(params, s)
  end
