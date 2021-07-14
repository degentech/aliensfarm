type vault_storage is [@layout:comb] record [
  account_info        : big_map(address, account); 
  total_staked        : nat; 
  total_reward        : nat; 
  share_reward        : nat; 
  dev_reserves        : nat; 
  tmp_put_pool        : nat; 
  admin_address       : address; 
  coin_address        : address; 
  pool_address        : address; 
  farm_address        : address; 
  referral_system     : address; 
]
