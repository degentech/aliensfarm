type farming_storage is [@layout:comb] record [
  account_info        : big_map(address, account); 
  vaults              : set(address); 
  last_updated        : timestamp; 
  total_staked        : nat; 
  share_reward        : nat; 
  coin_address        : address; 
  pool_address        : address; 
  burn_address        : address; 
  admin_address       : address; 
  reward_per_second   : nat; 
  coefficient         : nat; 
  referral_system     : address; 
]
