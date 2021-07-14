function update_rewards(var s : storage) : storage is
  block {
    if s.total_staked = 0n then
      skip
    else block {
      const new_reward : nat = abs(Tezos.now - s.last_updated) * s.reward_per_second * s.coefficient * number_accurancy;

      s.share_reward := s.share_reward + new_reward / s.total_staked / coefficient_decimals;
    };

    s.last_updated := Tezos.now;
  } with s

function change_rps_and_coefficient(const params : change_rps_and_coefficient_params; var s : storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
#if STAKING
      failwith("Staking/not-admin")
#else
      failwith("Farming/not-admin")
#endif
    else
      skip;

    if params.0 > s.reward_per_second then
#if STAKING
      failwith("Staking/too-high-rps")
#else
      failwith("Farming/too-high-rps")
#endif
    else
      s.reward_per_second := params.0;

    s.coefficient := params.1;
  } with (no_operations, s)


function join(const value : nat; const ref_addr : address; var s : storage) : return is
  block {
    if ref_addr = Tezos.sender then
#if STAKING
      failwith("Staking/can-not-refer-yourself")
#else
      failwith("Farming/can-not-refer-yourself")
#endif
    else
      skip;

    
    s := update_rewards(s);

    
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
#if STAKING
      get_paul_transfer_contract(s.coin_address)
#else
      get_paul_transfer_contract(s.pool_address)
#endif
    )
  ], s)


function quit(var value : nat; const recipient : address; var s : storage) : return is
  block {
    
    s := update_rewards(s);

    
    var acc : account := get_account(Tezos.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    if value = 0n then
      value := acc.amount
    else
      skip;

    
    if value <= acc.amount then
      skip
    else
#if STAKING
      failwith("Staking/balance-too-low");
#else
      failwith("Farming/balance-too-low");
#endif

    
    acc.amount := abs(acc.amount - value);

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[Tezos.sender] := acc;

    
    s.total_staked := abs(s.total_staked - value);
  } with (
    list [Tezos.transaction(
      Send(Tezos.self_address, (recipient, value)),
      0mutez,
#if STAKING
      get_paul_transfer_contract(s.coin_address)
#else
      get_paul_transfer_contract(s.pool_address)
#endif
    )], s)
