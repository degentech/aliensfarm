type staking_storage is [@layout:comb] record [
  account_info        : big_map(address, account); 
  last_updated        : timestamp; 
  total_staked        : nat; 
  share_reward        : nat; 
  coin_address        : address; 
  admin_address       : address; 
  reward_per_second   : nat; 
  coefficient         : nat; 
  referral_system     : address; 
]
