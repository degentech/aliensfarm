function get_token_burn_contract(const token_address : address) : contract(burn_type) is
  case (Tezos.get_entrypoint_opt("%burn", token_address) : option(contract(burn_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Burner/token-burn-entrypoint-not-found") : contract(burn_type))
  end

function get_quipuswap_contract(const pool_address : address) : contract(use_type) is
  case (Tezos.get_entrypoint_opt("%use", pool_address) : option(contract(use_type))) of
  | Some(contr) -> contr
  | None -> (failwith("Common/qp-pool-use-entrypoint-not-found") : contract(use_type))
  end
