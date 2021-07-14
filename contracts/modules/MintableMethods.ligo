
function burn(const src : address; const value : nat; var s : token_storage) : return is
  block {
    
    const user : account = get_account(src, s);

    
    if value = 0n then
      value := user.balance
    else
      skip;

    
    if user.balance < value then
      failwith("Token/not-enough-balance")
    else
      skip;

    
    if src =/= Tezos.sender then block {
      const allowance : nat = get_account_allowance(user, Tezos.sender);

      if allowance < value then
        failwith("Token/not-enough-allowance")
      else
        skip;

      
      user.allowances[Tezos.sender] := abs(allowance - value);
    } else
      skip;

    
    user.balance := abs(user.balance - value);

    
    s.ledger[src] := user;

    
    var zero_account : account := get_account(zero_address, s);

    
    zero_account.balance := zero_account.balance + value;

    
    s.ledger[zero_address] := zero_account;
  } with ((nil : list(operation)), s)


function mint(const l :list(address * nat); var s : token_storage) : return is
  block {
    
    if s.minters contains Tezos.sender then
      skip
    else
      failwith("Token/invalid-minter");

    function make_mint(var s : token_storage; const param : address * nat) : token_storage is
      block {
        
        const user : account = get_account(param.0, s);

        
        user.balance := user.balance + param.1;

        
        s.ledger[param.0] := user;

        
        s.total_supply := s.total_supply + param.1;
      } with s;

    s := List.fold(make_mint, l, s);
  } with ((nil : list(operation)), s)


function set_minter(const minter : address; const flag : bool; var s : token_storage) : return is
  block {
    
    if s.admin =/= Tezos.sender then
      failwith("Token/invalid-admin")
    else
      skip;

    
    s.minters := if flag then
      Set.add(minter, s.minters)
    else
      Set.remove(minter, s.minters);
  } with ((nil : list(operation)), s)
