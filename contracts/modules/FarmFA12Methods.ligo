
function get_account_allowance(const owner_account : account; const spender : address) : nat is
  case owner_account.permit[spender] of
  | Some(nat) -> nat
  | None -> 0n
  end


function transfer(const src : address; const dst : address; const value : nat; var s : storage) : return is
  block {
    
#if UPDATE_REWARDS_ENABLED
    s := update_rewards(s);
#endif

    
    if src = dst then
      failwith("Token/self-to-self-transfer")
    else
      skip;

    
    var sender_account : account := get_account(src, s);

    
    if sender_account.amount < value then
      failwith("Token/low-amount")
    else
      skip;

    
    if src =/= Tezos.sender then block {
      const spender_allowance : nat = get_account_allowance(sender_account, Tezos.sender);

      if spender_allowance < value then
        failwith("Token/not-enough-allowance")
      else
        skip;

      
      sender_account.permit[Tezos.sender] := abs(spender_allowance - value);
    } else
      skip;

    
    sender_account.reward := sender_account.reward + abs(sender_account.amount * s.share_reward - sender_account.former);

    
    sender_account.amount := abs(sender_account.amount - value);

    
    sender_account.former := sender_account.amount * s.share_reward;

    
    s.account_info[src] := sender_account;

    
    var dest_account : account := get_account(dst, s);

    
    dest_account.reward := dest_account.reward + abs(dest_account.amount * s.share_reward - dest_account.former);

    
    dest_account.amount := dest_account.amount + value;

    
    dest_account.former := dest_account.amount * s.share_reward;

    
    s.account_info[dst] := dest_account;
  } with ((nil : list(operation)), s)


function approve(const spender : address; const value : nat; var s : storage) : return is
  block {
    if spender = Tezos.sender then
      failwith("Token/self-to-self-approval")
    else
      skip;

    
    var sender_account : account := get_account(Tezos.sender, s);

    
    sender_account.permit[spender] := value;

    
    s.account_info[Tezos.sender] := sender_account;
  } with ((nil : list(operation)), s)


function get_balance(const owner : address; const contr : contract(nat); const s : storage) : return is
  block {
    const owner_account : account = get_account(owner, s);
  } with (list [transaction(owner_account.amount, 0tz, contr)], s)


function get_allowance(const owner : address; const spender : address; const contr : contract(nat); const s : storage) : return is
  block {
    const owner_account : account = get_account(owner, s);
    const spender_allowance : nat = get_account_allowance(owner_account, spender);
  } with (list [transaction(spender_allowance, 0tz, contr)], s)


function get_total_supply(const contr : contract(nat); const s : storage) : return is
  (list [transaction(s.total_staked, 0tz, contr)], s)
