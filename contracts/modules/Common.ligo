function get_set_referrer_contract(const referral_system : address) : contract(set_referrer_type) is
  case (Tezos.get_entrypoint_opt("%setReferrer", referral_system) : option(contract(set_referrer_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/set-referrer-entrypoint-not-found") : contract(set_referrer_type))
  end

function get_referral_info_contract(const referral_system : address) : contract(get_referral_info_type) is
  case (Tezos.get_entrypoint_opt("%getReferralInfo", referral_system) : option(contract(get_referral_info_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/get-referral-info-entrypoint-not-found") : contract(get_referral_info_type))
  end

function get_paul_transfer_contract(const token_address : address) : contract(send_type) is
  case (Tezos.get_entrypoint_opt("%transfer", token_address) : option(contract(send_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/token-transfer-entrypoint-not-found") : contract(send_type))
  end

function get_paul_mint_contract(const token_address : address) : contract(mint_type) is
  case (Tezos.get_entrypoint_opt("%mint", token_address) : option(contract(mint_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/token-mint-entrypoint-not-found") : contract(mint_type))
  end

function get_quipuswap_contract(const pool_address : address) : contract(use_type) is
  case (Tezos.get_entrypoint_opt("%use", pool_address) : option(contract(use_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/qp-pool-use-entrypoint-not-found") : contract(use_type))
  end

function change_referral_system(const new_referral_system : address; var s : storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
      failwith("Common/not-admin");
    else
      s.referral_system := new_referral_system;
  } with (no_operations, s)

function change_admin(const new_admin : address; var s : storage) : return is
  block {
    if Tezos.sender =/= s.admin_address then
      failwith("Common/not-admin");
    else
      s.admin_address := new_admin;
  } with (no_operations, s)

function get_account(const owner : address; const s : storage) : account is
  case s.account_info[owner] of
  | None -> record [
    amount = 0n;
    reward = 0n;
    former = 0n;
    permit = (map [] : map(address, nat));
  ]
  | Some(acc) -> acc
  end
