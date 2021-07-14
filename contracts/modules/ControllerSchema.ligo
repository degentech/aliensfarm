type controller_storage is [@layout:comb] record [
  admin                : address; 
  stakings             : big_map(nat, address); 
  farmings             : big_map(nat, address); 
  vaults               : big_map(nat, address); 
  tmp                  : big_map(address, account); 
  stakings_count       : nat; 
  farmings_count       : nat; 
  vaults_count         : nat; 
]

type deploy_staking_params is staking_storage

type deploy_farming_params is farming_storage

type deploy_vault_params is vault_storage

type controller_return is list(operation) * controller_storage

type change_referral_system_params is [@layout:comb] record [
  farm_address         : address; 
  new_referral_system  : address; 
]

type change_rps_and_coefficient_params is [@layout:comb] record [
  farm_address         : address; 
  new_rps              : nat; 
  new_coefficient      : nat; 
]

type chang_farm_admin_params is [@layout:comb] record [
  farm_address         : address; 
  new_admin            : address; 
]

type fund_vault_dev_reserves_params is address * address

type chang_admin_params is address

type register_vault_params is [@layout:comb] record [
  farm_address         : address; 
  vault_address        : address; 
  register             : bool; 
]

type burn_params is address

type controller_action is
| DeployStaking of staking_storage
| DeployFarming of farming_storage
| DeployVault of vault_storage
| ChangeReferralSystem of change_referral_system_params
| ChangeRPSAndCoefficient of change_rps_and_coefficient_params
| ChangeFarmAdmin of chang_farm_admin_params
| FundVaultDevReserves of fund_vault_dev_reserves_params
| ChangeAdmin of chang_admin_params
| RegisterVault of register_vault_params
| BurnPauls of burn_params

type deploy_staking_func is (option(key_hash) * tez * staking_storage) -> (operation * address)

type deploy_farming_func is (option(key_hash) * tez * farming_storage) -> (operation * address)

type deploy_vault_func is (option(key_hash) * tez * vault_storage) -> (operation * address)

type change_referral_system_type is ChangeRefSystem of address
type change_rps_type is ChangeRPSAndCoeff of nat * nat
type fund_type is Fund of address
type change_farm_admin_type is ChangeFarmAdm of address
type register_vault_type is RegVault of address * bool
type burn_type is Burn of unit
