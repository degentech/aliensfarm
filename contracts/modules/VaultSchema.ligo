#define VAULT

type put_type is Put of nat * address
type pull_type is Pull of nat * address
type farm_type is Farm of address
type approve_type is Accept of michelson_pair(address, "spender", nat, "value")
type bal_type is GetBal of michelson_pair(address, "owner", contract(nat), "")

type join_params is nat * address
type quit_params is nat
type earn_params is address
type swap_params is record [
  max_invs            : nat;
  max_swap            : nat;
  put_farm            : nat;
  put_pool            : nat;
]
type sync_params is nat
type fund_params is address
type change_referral_system_params is address
type change_admin_params is address
type storage is vault_storage

type return is list(operation) * vault_storage

type vault_action is
| Default
| Join                  of join_params
| Quit                  of quit_params
| Earn                  of earn_params
| Swap                  of swap_params
| Sync                  of sync_params
| Fund                  of fund_params
| ChangeReferralSystem  of change_referral_system_params
| ChangeAdmin           of change_admin_params

| Transfer              of transfer_params
| Approve               of approve_params
| GetBalance            of balance_params
| GetAllowance          of allowance_params
| GetTotalSupply        of total_supply_params

[@inline] const harvest_fee : nat = 3000000000000000000n; // 3 * 10**18

[@inline] const withdraw_fee : nat = 300000000000000000n; // 0.3 * 10**18

[@inline] const decimals18 : nat = 1000000000000000000n; // 10**18
