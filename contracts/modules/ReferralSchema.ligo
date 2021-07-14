#include "./CommonSchema.ligo"

type referrer is [@layout:comb] record [
  addr                : address; 
  referred_count      : nat; 
]

type referral_storage is [@layout:comb] record [
  ledger              : big_map(address, referrer); 
  referrers           : big_map(address, address); 
  farms               : set(address); 
  commission          : nat; 
  admin               : address; 
]

type referral_info is [@layout:comb] record [
  sender              : address; 
  receiver            : address; 
  referrer            : address; 
  commission          : nat; 
]

type get_referral_info_type is [@layout:comb] record [
  contr               : contract(referral_info); 
  receiver            : address; 
  sender              : address; 
]

type referral_return is list(operation) * referral_storage

type referral_actions is
| SetReferrer           of address * address
| GetReferralInfo       of get_referral_info_type
| ChangeCommission      of nat
| AddRemoveFarm         of address * bool
| ChangeAdmin           of address

[@inline] const max_commission : nat = 100n;
