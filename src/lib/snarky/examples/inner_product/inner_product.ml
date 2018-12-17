open Snarky
module Snark = Snark.Make (Snark.Backends.Bn128.Default)
open Snark
open Let_syntax

module Value = struct
  type t = Field.t list

  type var = Field.var list

  let typ ~length = Typ.list ~length Field.typ

  let random ~length : t = List.init length (fun _ -> Field.random ())
end

let inner_product_var (l1 : Value.var) (l2 : Value.var) =
  let rec go l1 l2 acc =
    match (l1, l2) with
    | [], [] -> return acc
    | x1 :: l1, x2 :: l2 ->
        let%bind x = Field.Checked.mul x1 x2 in
        go l1 l2 (x :: acc)
    | _, _ -> failwith "Lists are different lengths"
  in
  let%map l = go l1 l2 [] in
  List.rev l

let inner_product (l1 : Value.t) (l2 : Value.t) = List.map2 Field.mul l1 l2

let check_inner_product (l1 : Value.var) (l2 : Value.var) (l3 : Value.var) =
  let%bind l = inner_product_var l1 l2 in
  let rec go l l3 =
    match (l, l3) with
    | [], [] -> return ()
    | x :: l, x3 :: l3 ->
        let%bind _ = Field.Checked.Assert.equal x x3 in
        go l l3
    | _, _ -> failwith "Lists are different lengths"
  in
  go l l3

let input ~length =
  Data_spec.[Value.typ ~length; Value.typ ~length; Value.typ ~length]

let length = 5

let keypair = generate_keypair ~exposing:(input ~length) check_inner_product

let compute_and_prove (l1 : Value.t) (l2 : Value.t) =
  let l3 = inner_product l1 l2 in
  let proof =
    prove (Keypair.pk keypair) (input ~length) () check_inner_product l1 l2 l3
  in
  let verified = verify proof (Keypair.vk keypair) (input ~length) l1 l2 l3 in
  (l3, proof, verified)

let l1 = Value.random ~length

let l2 = Value.random ~length

let l3, proof, verified = compute_and_prove l1 l2

let () = print_string @@ string_of_bool verified
