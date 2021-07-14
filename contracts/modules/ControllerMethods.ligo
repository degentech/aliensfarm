const deploy_staking : deploy_staking_func =
[%Michelson(
  {|
    {
      UNPPAIIR;
      CREATE_CONTRACT
#include "../compiled/Staking.tz"
      ;
      PAIR;
    }
  |} : deploy_staking_func
)];

const deploy_farming : deploy_farming_func =
[%Michelson(
  {|
    {
      UNPPAIIR;
      CREATE_CONTRACT
#include "../compiled/Farming.tz"
      ;
      PAIR;
    }
  |} : deploy_farming_func
)];

const deploy_vault : deploy_vault_func =
[%Michelson(
  {|
    {
      UNPPAIIR;
      CREATE_CONTRACT
#include "../compiled/Vault.tz"
      ;
      PAIR;
    }
  |} : deploy_vault_func
)];

function get_change_referral_system_contract(const farm : address) : contract(change_referral_system_type) is
  case (Tezos.get_entrypoint_opt("%changeReferralSystem", farm) : option(contract(change_referral_system_type))) of
  | Some(v) -> v
  | None -> (failwith("Controller/change-referral-system-entrypoint-not-found") : contract(change_referral_system_type))
  end

function get_change_admin_contract(const farm : address) : contract(change_farm_admin_type) is
  case (Tezos.get_entrypoint_opt("%changeAdmin", farm) : option(contract(change_farm_admin_type))) of
  | Some(v) -> v
  | None -> (failwith("Controller/change-admin-entrypoint-not-found") : contract(change_farm_admin_type))
  end

function get_change_rps_contract(const farm : address) : contract(change_rps_type) is
  case (Tezos.get_entrypoint_opt("%changeRPSAndCoeff", farm) : option(contract(change_rps_type))) of
  | Some(v) -> v
  | None -> (failwith("Controller/change-rps-and-coeff-entrypoint-not-found") : contract(change_rps_type))
  end

function get_vault_fund_contract(const vault : address) : contract(fund_type) is
  case (Tezos.get_entrypoint_opt("%fund", vault) : option(contract(fund_type))) of
  | Some(v) -> v
  | None -> (failwith("Controller/vault-fund-entrypoint-not-found") : contract(fund_type))
  end

function get_register_vault_contract(const farm : address) : contract(register_vault_type) is
  case (Tezos.get_entrypoint_opt("%registerVault", farm) : option(contract(register_vault_type))) of
  | Some(v) -> v
  | None -> (failwith("Controller/farming-register-vault-entrypoint-not-found") : contract(register_vault_type))
  end

function get_burn_contract(const farm : address) : contract(unit) is
  case (Tezos.get_entrypoint_opt("%burn", farm) : option(contract(unit))) of
  | Some(v) -> v
  | None -> (failwith("Controller/farming-burn-entrypoint-not-found") : contract(unit))
  end

function deploy_staking(const storage : staking_storage; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);

    storage.account_info := s.tmp;

    const res : (operation * address) = deploy_staking((None : option(key_hash)), 0mutez, storage);

    s.stakings[s.stakings_count] := res.1;
    s.stakings_count := s.stakings_count + 1n;
  } with (list [res.0], s)

function deploy_farming(const storage : farming_storage; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);

    storage.account_info := s.tmp;

    const res : (operation * address) = deploy_farming((None : option(key_hash)), 0mutez, storage);

    s.farmings[s.farmings_count] := res.1;
    s.farmings_count := s.farmings_count + 1n;
  } with (list [res.0], s)

function deploy_vault(const storage : vault_storage; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);

    storage.account_info := s.tmp;

    const res : (operation * address) = deploy_vault((None : option(key_hash)), 0mutez, storage);

    s.vaults[s.vaults_count] := res.1;
    s.vaults_count := s.vaults_count + 1n;
  } with (list [
    res.0;
    Tezos.transaction(
      RegVault(res.1, True),
      0mutez,
      get_register_vault_contract(storage.farm_address)
    )
  ], s)

function change_referral_system(const params : change_referral_system_params; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      ChangeRefSystem(params.new_referral_system),
      0mutez,
      get_change_referral_system_contract(params.farm_address)
    )
  ], s)

function change_rps_and_coefficient(const params : change_rps_and_coefficient_params; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      ChangeRPSAndCoeff(params.new_rps, params.new_coefficient),
      0mutez,
      get_change_rps_contract(params.farm_address)
    )
  ], s)

function change_farm_admin(const params : chang_farm_admin_params; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      ChangeFarmAdm(params.new_admin),
      0mutez,
      get_change_admin_contract(params.farm_address)
    )
  ], s)

function fund_vault_dev_reserves(const vault : address; const recipient : address; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      Fund(recipient),
      0mutez,
      get_vault_fund_contract(vault)
    )
  ], s)

function register_vault(const params : register_vault_params; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      RegVault(params.vault_address, params.register),
      0mutez,
      get_register_vault_contract(params.farm_address)
    )
  ], s)

function burn_pauls(const farm : address; const s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);
  } with (list [
    Tezos.transaction(
      unit,
      0mutez,
      get_burn_contract(farm)
    )
  ], s)

function change_admin(const new_admin : address; var s : controller_storage) : controller_return is
  block {
    assert(Tezos.sender = s.admin);

    s.admin := new_admin;
  } with (no_operations, s)
