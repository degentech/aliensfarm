#define STAKING

type join_params is nat * address
type quit_params is nat * address
type earn_params is address * bool
type earn_callback_params is referral_info
type change_referral_system_params is address
type change_admin_params is address
type storage is staking_storage

type return is list(operation) * staking_storage

type staking_action is
| Join                  of join_params
| Quit                  of quit_params
| Earn                  of earn_params
| EarnCallback          of earn_callback_params
| EarnAndJoinCallback   of earn_callback_params
| ChangeReferralSystem  of change_referral_system_params
| ChangeRPSAndCoeff     of change_rps_and_coefficient_params
| ChangeAdmin           of change_admin_params

| Transfer              of transfer_params
| Approve               of approve_params
| GetBalance            of balance_params
| GetAllowance          of allowance_params
| GetTotalSupply        of total_supply_params
