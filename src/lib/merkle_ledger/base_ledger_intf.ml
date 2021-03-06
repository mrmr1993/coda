open Core

module type S = sig
  type root_hash

  type hash

  type account

  type key

  type index = int

  (* no deriving, purposely; signatures that include this one may add deriving *)
  type t

  module Addr : Merkle_address.S

  module Path : Merkle_path.S with type hash := hash

  module Location : sig
    type t [@@deriving sexp, compare, hash, eq]
  end

  include
    Syncable_intf.S
    with type root_hash := root_hash
     and type hash := hash
     and type account := account
     and type addr := Addr.t
     and type path = Path.t
     and type t := t

  val to_list : t -> account list

  val foldi :
    t -> init:'accum -> f:(Addr.t -> 'accum -> account -> 'accum) -> 'accum

  val fold_until :
       t
    -> init:'accum
    -> f:('accum -> account -> ('accum, 'stop) Base.Continue_or_stop.t)
    -> finish:('accum -> 'stop)
    -> 'stop

  val location_of_key : t -> key -> Location.t option

  val get_or_create_account :
    t -> key -> account -> ([`Added | `Existed] * Location.t) Or_error.t

  val get_or_create_account_exn :
    t -> key -> account -> [`Added | `Existed] * Location.t

  val destroy : t -> unit

  val get_uuid : t -> Uuid.t

  val get : t -> Location.t -> account option

  val set : t -> Location.t -> account -> unit

  val set_batch : t -> (Location.t * account) list -> unit

  val get_at_index_exn : t -> int -> account

  val set_at_index_exn : t -> int -> account -> unit

  val index_of_key_exn : t -> key -> int

  val merkle_root : t -> root_hash

  val merkle_path : t -> Location.t -> Path.t

  val merkle_path_at_index_exn : t -> int -> Path.t

  val remove_accounts_exn : t -> key list -> unit

  val copy : t -> t
end
