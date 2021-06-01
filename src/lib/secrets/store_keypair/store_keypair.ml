open Core_kernel
open Async
open Signature_lib

let mk_keypair privkey =
  let module Field = Marlin_plonk_bindings_pasta_fq in
  let field_size =
    Field.size ()
    |> Marlin_plonk_bindings_bigint_256.to_string
    |> Bigint.of_string
  in
  let privkey_bigint = ref (Bigint.of_string privkey) in
  (* Slow but easy mod operation. Don't use huge input numbers with this!
     Something ~256 bits (64 hex characters) is best, e.g. shasum -a 256
  *)
  while Bigint.(!privkey_bigint >= field_size) do
    privkey_bigint := Bigint.(!privkey_bigint - field_size)
  done;
  let privkey_decimal = Bigint.to_string !privkey_bigint in
  let privkey_field = Field.of_string privkey_decimal in
  privkey_field

let use_privkey privkey_field =
  let pk = Public_key.of_private_key_exn privkey_field in
  let message : Schnorr.Message.t = 
    { field_elements=
        Marlin_plonk_bindings_pasta_fp.[|
          of_int 0
        ; of_int 1
        ; of_int 15
        ; of_int 30
        ; of_int 10000|]
    ; bitstrings=
        [| [true; false; false]; [true; false]; [false]; [false]; [true; true] |] }
  in
  let test_sig = Schnorr.sign privkey_field message in
  let pk_curve = Marlin_plonk_bindings_pasta_pallas.of_affine (Finite pk) in
  assert (Schnorr.verify test_sig pk_curve message) ;
  let pk_compressed = Public_key.compress pk in
  Public_key.Compressed.to_base58_check pk_compressed;;

let () =
  Command.run
    (Command.async
       ~summary:"Generate a keyfile from some seed data"
       (let%map_open.Command.Let_syntax data = flag "data" ~doc:"DATA" (required string)
        and password = flag "password" ~doc:"PASSWORD" (required string)
       in
       (fun () ->
        let privkey = mk_keypair data in
        let pubkey = use_privkey privkey in
        Secrets.Keypair.write_exn (Keypair.of_private_key_exn privkey) ~privkey_path:pubkey ~password:(lazy (Deferred.return (Bytes.of_string password)))
       )))
