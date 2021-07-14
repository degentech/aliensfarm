#include "./Common.ligo"
#include "./CommonStakingFarming.ligo"

function get_staking_earn_callback_contract(const self : address) : contract(referral_info) is
  case (Tezos.get_entrypoint_opt("%earnCallback", self) : option(contract(referral_info))) of
  | Some(contr) -> contr
  | None -> (failwith("Staking/earn-callback-entrypoint-not-found") : contract(referral_info))
  end

function get_staking_earn_and_join_callback_contract(const self : address) : contract(referral_info) is
  case (Tezos.get_entrypoint_opt("%earnAndJoinCallback", self) : option(contract(referral_info))) of
  | Some(contr) -> contr
  | None -> (failwith("Staking/earn-and-join-callback-entrypoint-not-found") : contract(referral_info))
  end


function earn(const receiver : address; const earn_and_join : bool; const s : staking_storage) : return is
  block {
    var params : get_referral_info := record [
      contr = get_staking_earn_callback_contract(Tezos.self_address);
      receiver = receiver;
      sender = Tezos.sender;
    ];

    if earn_and_join then
      params.contr := get_staking_earn_and_join_callback_contract(Tezos.self_address)
    else
      skip;
  } with (list [
    Tezos.transaction(
      GetReferralInfoType(params),
      0mutez,
      get_referral_info_contract(s.referral_system)
    )
  ], s)


function earn_callback(const referral_system_info : referral_info; var s : staking_storage) : return is
  block {
    if Tezos.sender =/= s.referral_system then
      failwith("Staking/not-referral-system")
    else
      skip;

    
    s := update_rewards(s);

    
    var acc : account := get_account(referral_system_info.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    var operations : list(operation) := no_operations;

    
    const reward : nat = acc.reward / number_accurancy;

    
    if reward = 0n then
      skip
    else block {
      
      acc.reward := abs(acc.reward - reward * number_accurancy);

      const actual_paid : nat = reward * abs(100n - referral_system_info.commission) / 100n;
      const referral_commission : nat = abs(reward - actual_paid);
      const mint_data : list(address * nat) = list [
        (referral_system_info.referrer, referral_commission);
        (referral_system_info.receiver, actual_paid)
      ];

      
      operations := Tezos.transaction(
        Mint(mint_data),
        0mutez,
        get_paul_mint_contract(s.coin_address)
      ) # operations;
    };

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[referral_system_info.sender] := acc;
  } with (operations, s)


function earn_and_join_callback(const referral_system_info : referral_info; var s : staking_storage) : return is
  block {
    if Tezos.sender =/= s.referral_system then
      failwith("Staking/not-referral-system")
    else
      skip;

    var actual_paid : nat := 0n;

    
    s := update_rewards(s);

    
    var acc : account := get_account(referral_system_info.sender, s);

    
    acc.reward := acc.reward + abs(acc.amount * s.share_reward - acc.former);

    
    var operations : list(operation) := no_operations;

    
    const reward : nat = acc.reward / number_accurancy;

    
    if reward = 0n then
      skip
    else block {
      
      acc.reward := abs(acc.reward - reward * number_accurancy);

      actual_paid := reward * abs(100n - referral_system_info.commission) / 100n;

      const referral_commission : nat = abs(reward - actual_paid);
      const mint_data : list(address * nat) = list [
        (referral_system_info.referrer, referral_commission);
        (Tezos.self_address, actual_paid)
      ];

      
      operations := Tezos.transaction(
        Mint(mint_data),
        0mutez,
        get_paul_mint_contract(s.coin_address)
      ) # operations;
    };

    
    acc.amount := acc.amount + actual_paid;

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[referral_system_info.sender] := acc;

    
    s.total_staked := s.total_staked + actual_paid;
  } with (operations, s)
