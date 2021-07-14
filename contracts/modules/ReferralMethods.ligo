function get_referrer(const ref_addr : address; const s : referral_storage) : referrer is
  block {
    const ref : referrer = case s.ledger[ref_addr] of
    | Some(v) -> v
    | None -> record [
      addr = ref_addr;
      referred_count = 0n;
    ]
    end;
  } with ref

function set_ref(const user : address; const ref_addr : address; var s : referral_storage) : referral_storage is
  block {
    case s.referrers[user] of
    | Some(v) -> skip
    | None -> block {
      var ref : referrer := get_referrer(ref_addr, s);

      ref.referred_count := ref.referred_count + 1n;
      s.ledger[ref_addr] := ref;
      s.referrers[user] := ref_addr;
    }
    end;
  } with s

function get_referral_info(const data : get_referral_info_type; const s : referral_storage) : referral_return is
  block {
    var operations : list(operation) := no_operations;

    if s.farms contains Tezos.sender then block {
      const referrer : address = case s.referrers[data.sender] of
      | Some(v) -> v
      | None -> (failwith("ReferralSystem/referrer-not-found") : address)
      end;
      const referral_info : referral_info = record [
        sender = data.sender;
        receiver = data.receiver;
        referrer = referrer;
        commission = s.commission;
      ];

      operations := Tezos.transaction(referral_info, 0mutez, data.contr) # operations;
    } else
      failwith("ReferralSystem/sender-is-not-farm");
  } with (operations, s)

function set_referrer(const user : address; const ref_addr : address; var s : referral_storage) : referral_return is
  block {
    if s.farms contains Tezos.sender then block {
      if ref_addr = user then
        failwith("ReferralSystem/can-not-refer-yourself")
      else
        skip;

      s := set_ref(user, ref_addr, s);
    } else
      failwith("ReferralSystem/sender-is-not-farm");
  } with (no_operations, s)

function change_commission(const new_commission : nat; var s : referral_storage) : referral_return is
  block {
    if Tezos.sender =/= s.admin then
      failwith("ReferralSystem/not-admin")
    else if new_commission > max_commission then
      failwith("ReferralSystem/too-high-commission")
    else
      s.commission := new_commission;
  } with (no_operations, s)

function change_admin(const new_admin : address; var s : referral_storage) : referral_return is
  block {
    if Tezos.sender =/= s.admin then
      failwith("ReferralSystem/not-admin")
    else
      s.admin := new_admin;
  } with (no_operations, s)

function add_remove_farm(const farm : address; const flag : bool; var s : referral_storage) : referral_return is
  block {
    if Tezos.sender =/= s.admin then
      failwith("ReferralSystem/not-admin")
    else if flag then
      s.farms := Set.add(farm, s.farms)
    else
      s.farms := Set.remove(farm, s.farms);
  } with (no_operations, s)
