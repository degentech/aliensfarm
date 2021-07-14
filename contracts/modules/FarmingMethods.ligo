#include "./Common.ligo"
#include "./CommonStakingFarming.ligo"

function get_farming_earn_callback_contract(const self : address) : contract(referral_info) is
  case (Tezos.get_entrypoint_opt("%earnCallback", self) : option(contract(referral_info))) of
  | Some(contr) -> contr
  | None -> (failwith("Farming/earn-callback-entrypoint-not-found") : contract(referral_info))
  end


function earn(const receiver : address; const s : farming_storage) : return is
  block {
    skip;
  } with (list [
    Tezos.transaction(
      GetReferralInfoType(record [
        contr = get_farming_earn_callback_contract(Tezos.self_address);
        sender = Tezos.sender;
        receiver = receiver;
      ]),
      0mutez,
      get_referral_info_contract(s.referral_system)
    )
  ], s)


function earn_callback(const referral_system_info : referral_info; var s : farming_storage) : return is
  block {
    if Tezos.sender =/= s.referral_system then
      failwith("Farming/not-referral-system")
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

      if s.vaults contains referral_system_info.sender then block {
        const mint_data : list(address * nat) = list [
          (referral_system_info.receiver, reward)
        ];

        
        operations := Tezos.transaction(
          Mint(mint_data),
          0mutez,
          get_paul_mint_contract(s.coin_address)
        ) # operations;
      } else block {
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
    };

    
    acc.former := acc.amount * s.share_reward;

    
    s.account_info[referral_system_info.sender] := acc;
  } with (operations, s)


function burn(const s : farming_storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
      failwith("Farming/not-admin")
    else
      skip;
  } with
  (list [
    Tezos.transaction(
      WithdrawProfit(s.burn_address),
      0mutez,
      get_quipuswap_contract(s.pool_address)
    )
  ], s)


function register_vault(const vault : address; const register : bool; var s : farming_storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
      failwith("Farming/not-admin");
    else if register then
      s.vaults := Set.add(vault, s.vaults)
    else
      s.vaults := Set.remove(vault, s.vaults);
  } with (no_operations, s)
