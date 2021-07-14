#include "./Common.ligo"

function get_put_contract(const farming : address) : contract(put_type) is
  case (Tezos.get_entrypoint_opt("%join", farming) : option(contract(put_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/farming-join-entrypoint-not-found") : contract(put_type))
  end

function get_pull_contract(const farming : address) : contract(pull_type) is
  case (Tezos.get_entrypoint_opt("%quit", farming) : option(contract(pull_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/farming-quit-entrypoint-not-found") : contract(pull_type))
  end

function get_approve_contract(const token : address) : contract(approve_type) is
  case (Tezos.get_entrypoint_opt("%approve", token) : option(contract(approve_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/token-approve-entrypoint-not-found") : contract(approve_type))
  end

function get_earn_contract(const farming : address) : contract(farm_type) is
  case (Tezos.get_entrypoint_opt("%earn", farming) : option(contract(farm_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/farming-earn-entrypoint-not-found") : contract(farm_type))
  end

function get_balance_contract(const token : address) : contract(bal_type) is
  case (Tezos.get_entrypoint_opt("%getBalance", token) : option(contract(bal_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/token-get-balance-entrypoint-not-found") : contract(bal_type))
  end

function get_token_contract(const token : address) : contract(send_type) is
  case (Tezos.get_entrypoint_opt("%transfer", token) : option(contract(send_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/token-transfer-entrypoint-not-found") : contract(send_type))
  end

function get_balance_callback_contract(const self : address) : contract(nat) is
  case (Tezos.get_entrypoint_opt("%sync", self) : option(contract(nat))) of
  | Some(contr) -> contr
  | None -> (failwith("Vault/sync-entrypoint-not-found") : contract(nat))
  end


function join(const value : nat; const ref_addr : address; var s : vault_storage) : return is
  block {
    if ref_addr = Tezos.sender then
      failwith("Vault/can-not-refer-yourself")
    else
      skip;

    
    var acc : account := get_account(Tezos.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    acc.amount := acc.amount + value;

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[Tezos.sender] := acc;

    
    s.total_staked := s.total_staked + value;
  } with (list [
    Tezos.transaction(
      SetRef(Tezos.sender, ref_addr),
      0mutez,
      get_set_referrer_contract(s.referral_system)
    );
    Tezos.transaction(
      Send(Tezos.sender, (Tezos.self_address, value)),
      0mutez,
      get_token_contract(s.pool_address)
    );
    Tezos.transaction(
      Accept(s.farm_address, value),
      0mutez,
      get_approve_contract(s.pool_address)
    );
    Tezos.transaction(
      Put(value, zero_address),
      0mutez,
      get_put_contract(s.farm_address)
    )
  ], s)


function quit(const value : nat; const s : vault_storage) : return is
  block {
    
    var acc : account := get_account(Tezos.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    if value = 0n then
      value := acc.amount
    else
      skip;

    
    if value <= acc.amount then
      skip
    else
      failwith("Vault/balance-too-low");

    
    const fee : nat = (((withdraw_fee * value) / 100n) / decimals18);

    s.dev_reserves := s.dev_reserves + fee;

    
    acc.amount := abs(acc.amount - value);

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[Tezos.sender] := acc;

    
    s.total_staked := abs(s.total_staked - value);
  } with (list [
    Tezos.transaction(
      Pull(abs(value - fee), Tezos.sender),
      0mutez,
      get_pull_contract(s.farm_address)
    )
  ], s)


function earn(const receiver : address; var s : vault_storage) : return is
  block {
    
    var acc : account := get_account(Tezos.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    var operations : list(operation) := no_operations;

    
    const reward : nat = acc.reward / number_accurancy;

    
    if reward = 0n then
      skip
    else block {
      
      acc.reward := abs(acc.reward - reward * number_accurancy);

      
      operations := Tezos.transaction(
        Send(Tezos.self_address, (receiver, reward)),
        0mutez,
        get_token_contract(s.pool_address)
      ) # operations;

      operations := Tezos.transaction(
        Pull(reward, Tezos.self_address),
        0mutez,
        get_pull_contract(s.farm_address)
      ) # operations;
    };

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[Tezos.sender] := acc;
  } with (operations, s)


function fund(const receiver : address; var s : vault_storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
      failwith("Vault/not-admin")
    else
      skip;

    var operations : list(operation) := no_operations;

    if s.dev_reserves = 0n then
      failwith("Vault/zero-dev-reserves")
    else block {
      const value : nat = s.dev_reserves;

      s.dev_reserves := 0n;

      operations := Tezos.transaction(
        Pull(value, receiver),
        0mutez,
        get_pull_contract(s.farm_address)
      ) # operations;
    };
  } with (operations, s)


function swap(const params : swap_params; var s : vault_storage) : return is
  (list [
    Tezos.transaction(
      Farm(Tezos.self_address),
      0mutez,
      get_earn_contract(s.farm_address)
    );
    Tezos.transaction(
      Accept(s.pool_address, params.put_pool),
      0mutez,
      get_approve_contract(s.coin_address)
    );
    Tezos.transaction(
      Accept(s.farm_address, params.put_farm),
      0mutez,
      get_approve_contract(s.pool_address)
    );
    Tezos.transaction(
      TokenToTezPayment(record [
        amount    = params.max_swap;
        min_out   = 1n;
        receiver  = Tezos.self_address;
      ]),
      0mutez,
      get_quipuswap_contract(s.pool_address)
    )
  ], s with record [tmp_put_pool = params.max_invs])


function default(const s : vault_storage) : return is
  block {
    if s.pool_address =/= Tezos.sender then
      failwith("Vault/not-permitted")
    else
      skip;
  } with (list [
    Tezos.transaction(
      InvestLiquidity(s.tmp_put_pool),
      Tezos.amount,
      get_quipuswap_contract(s.pool_address)
    );
    Tezos.transaction(
      GetBal(Tezos.self_address, get_balance_callback_contract(Tezos.self_address)),
      0mutez,
      get_balance_contract(s.pool_address)
    )
  ], s)


function sync(const value : nat; var s : vault_storage) : return is
  block {
    if s.pool_address =/= Tezos.sender then
      failwith("Vault/not-permitted")
    else
      skip;

    
    const fee : nat = (((harvest_fee * value) / 100n) / decimals18);

    s.total_reward := s.total_reward + value;

    
    if s.total_staked =/= 0n then
      s.share_reward := s.share_reward + (abs(value - fee) * number_accurancy / s.total_staked)
    else
      skip;

    
    var acc : account := get_account(Tezos.source, s);

    
    const new_reward : nat = abs(acc.amount * s.share_reward - acc.former);

    
    acc.reward := acc.reward + new_reward + fee * number_accurancy;

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[Tezos.source] := acc;
  } with (list [
    Tezos.transaction(
      Put(value, zero_address),
      0mutez,
      get_put_contract(s.farm_address)
    )
  ], s)
