#include "./DexSchema.ligo"

type referral_info is [@layout:comb] record [
  sender              : address; 
  receiver            : address; 
  referrer            : address; 
  commission          : nat; 
]

type get_referral_info is [@layout:comb] record [
  contr               : contract(referral_info); 
  receiver            : address; 
  sender              : address; 
]

type account is [@layout:comb] record [
  amount              : nat; 
  reward              : nat; 
  former              : nat; 
  permit              : map(address, nat); 
]

type send_type is Send of michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type mint_type is Mint of list(address * nat)
type set_referrer_type is SetRef of address * address
type get_referral_info_type is GetReferralInfoType of get_referral_info
type use_type is dex_action
type change_rps_and_coefficient_params is nat * nat

type transfer_params is michelson_pair(address, "from", michelson_pair(address, "to", nat, "value"), "")
type approve_params is michelson_pair(address, "spender", nat, "value")
type balance_params is michelson_pair(address, "owner", contract(nat), "")
type allowance_params is michelson_pair(michelson_pair(address, "owner", address, "spender"), "", contract(nat), "")
type total_supply_params is unit * contract(nat)

[@inline] const no_operations : list(operation) = nil;

[@inline] const zero_address : address = ("tz1burnburnburnburnburnburnburjAYjjX" : address);

[@inline] const coefficient_decimals : nat = 100n;

[@inline] const number_accurancy : nat = 1000000000000000000n;
