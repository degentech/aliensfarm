type account_info is record [
  balance             : nat;
  frozen_balance      : nat;
  allowances          : map(address, nat);
]

type vote_info is record [
  candidate           : option(key_hash);
  vote                : nat;
  veto                : nat;
  last_veto           : timestamp;
]

type user_reward_info is record [
  reward              : nat;
  reward_paid         : nat;
]

type dex_storage is record [
  tez_pool            : nat;
  token_pool          : nat;
  token_address       : address;
  baker_validator     : address;
  total_supply        : nat;
  ledger              : big_map(address, account_info);
  voters              : big_map(address, vote_info);
  vetos               : big_map(key_hash, timestamp);
  votes               : big_map(key_hash, nat);
  veto                : nat;
  last_veto           : timestamp;
  current_delegated   : option(key_hash);
  current_candidate   : option(key_hash);
  total_votes         : nat;
  reward              : nat;
  total_reward        : nat;
  reward_paid         : nat;
  reward_per_share    : nat;
  reward_per_sec      : nat;
  last_update_time    : timestamp;
  period_finish       : timestamp;
  user_rewards        : big_map(address, user_reward_info);
]

type tez_to_token_payment_params is record [
  min_out             : nat;
  receiver            : address;
]

type token_to_tez_payment_params is record [
  amount              : nat;
  min_out             : nat;
  receiver            : address;
]

type divest_liquidity_params is record [
  min_tez             : nat;
  min_tokens          : nat;
  shares              : nat;
]

type vote_params is record [
  candidate           : key_hash;
  value               : nat;
  voter               : address;
]

type veto_params is record [
  value               : nat;
  voter               : address;
]

type dex_action is
| InitializeExchange  of nat
| TezToTokenPayment   of tez_to_token_payment_params
| TokenToTezPayment   of token_to_tez_payment_params
| InvestLiquidity     of nat
| DivestLiquidity     of divest_liquidity_params
| Vote                of vote_params
| Veto                of veto_params
| WithdrawProfit      of address

type default_params is unit
type use_params is dex_action
type get_reserves_params is contract(nat * nat)

type transfer_params is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type approve_params is michelson_pair(address, "spender", nat, "value")
type balance_params is michelson_pair(address, "owner", contract(nat), "")
type allowance_params is michelson_pair(michelson_pair(address, "owner", address, "spender"), "", contract(nat), "")
type total_supply_params is (unit * contract(nat))

type token_action is
| ITransfer           of transfer_params
| IApprove            of approve_params
| IGetBalance         of balance_params
| IGetAllowance       of allowance_params
| IGetTotalSupply     of total_supply_params

type return is list(operation) * dex_storage
type dex_func is (dex_action * dex_storage * address) -> return
type token_func is (token_action * dex_storage * address) -> return

type full_dex_storage is record [
  storage             : dex_storage;
  dex_lambdas         : big_map(nat, dex_func);
  metadata            : big_map(string, bytes);
  token_lambdas       : big_map(nat, token_func);
]

type full_return is list(operation) * full_dex_storage

const fee_rate : nat = 333n;
