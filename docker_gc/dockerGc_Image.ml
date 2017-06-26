(* DockerGc_Library -- Docker GC Library

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)
open Rashell_Docker_t

module StringPool =
  Set.Make(String)

type image = Rashell_Docker_t.image

type image_id = string

type image_ref = string

type repository = string

type tag = string

type description = {
  image: image;
  name: (repository * tag) list;
}

type policy =
  DockerGc_Policy.t

type predicate =
  DockerGc_Policy.predicate

let filtermap f lst =
  let fpack acc x =
    match f x with
    | Some(y) -> y :: acc
    | None -> acc
  in
  let rec loop acc r =
    match r with
    | hd :: tl -> loop (fpack acc hd) tl
    | [] -> List.rev acc
  in
  loop [] lst

module LibraryReader =
struct

  module Monad =
    Lemonade_Reader.Make(struct type t = (image_id * description) list end)

  include Monad
  open Monad.Infix

  let _program_start =
    Unix.gettimeofday ()

  let _lookup imageid env  =
    try List.assoc imageid env
    with Not_found -> failwith (imageid^": Image not found.")

  let _age n imageid env =
    let image = (_lookup imageid env).image in
    let seconds_per_day = float_of_int(24 * 60 * 60) in
    let t = Rashell_Timestamp.of_string image.image_created in
    (_program_start -. t) /. seconds_per_day  > (float_of_int n)

  let age n imageid =
    _age n imageid <$> read

  let _repositories imageid env =
    (_lookup imageid env).name
    |> List.map fst

  let _repository s imageid env =
    match _repositories imageid env with
    | [] -> s = ""
    | names -> List.mem s names

  let repository s imageid =
    _repository s imageid <$> read

  let _dandling imageid env =
    match _lookup imageid env with
    | { name = [] } -> true
    | _ -> false

  let dandling imageid =
    _dandling imageid <$> read

  let _leaves env =
    let _is_leaf env imageid =
      not(List.exists
            (fun (_, { image }) -> image.image_parent = Some(imageid)) env)
    in
    List.filter (_is_leaf env) (List.map fst env)

  let leaves =
    _leaves <$> read

  let _select ids action env =
    let open DockerGc_Policy in
    let _compare id1 id2 =
      (* Smallest for this order is the most recent *)
      let { image = img1 } = _lookup id1 env in
      let { image = img2 } = _lookup id2 env in
      Pervasives.compare img2.image_created img1.image_created
    in
    let _list_take n lst =
      List.fold_left
        (fun (acc, k) x -> if k >= n then (acc, k) else (x :: acc, (k+1)))
        ([], 0) lst
      |> fst
    in
    match action with
    | PreserveRecent(n) ->
        StringPool.elements ids
        |> List.sort _compare
        |> _list_take n
        |> StringPool.of_list
    | _ -> ids


  let select ids action =
    _select ids action <$> read

  let description imageid =
    _lookup imageid <$> read
end

let list () =
  let%lwt images = Rashell_Docker.images () in
  let%lwt tags = Rashell_Docker.tags () in
  let decorate image =
    (image.image_id, {
        image;
        name = (try List.assoc image.image_id tags with Not_found -> []);
      })
  in
  Lwt.return (List.map decorate images)

let rec eval imageid =
  let open DockerGc_Policy in
  let open LibraryReader.Infix in
  function
  | True -> LibraryReader.return true
  | False -> LibraryReader.return false
  | Age(n) -> LibraryReader.age n imageid
  | Repository(s)-> LibraryReader.repository s imageid
  | Dandling -> LibraryReader.dandling imageid
  | Not(expr) -> not <$> (eval imageid expr)
  | Or(a,b) -> ( || ) <$> (eval imageid a) <*> (eval imageid b)
  | And(a,b) -> ( && ) <$> (eval imageid a) <*> (eval imageid b)


let plan_predicate_matching policy imageid_lst =
  let open LibraryReader.Infix in
  let predicate_matching predicate =
    LibraryReader.filter
      (fun imageid -> eval imageid predicate)
      (List.map LibraryReader.return imageid_lst)
  in
  let f (predicate, action) =
    predicate_matching predicate
    >>= fun imageids ->
    LibraryReader.return
      (StringPool.of_list imageids,
       DockerGc_Policy.predicate_to_string predicate,
       action)
  in
  LibraryReader.dist (List.map f policy)

let plan_integrate ax (ids, reason, action) =
  let open LibraryReader.Infix in
  let preserve =
    let open DockerGc_Policy in
    match action with
    | Delete -> false
    | PreserveAll
    | PreserveRecent(_) -> true
  in
  LibraryReader.select ids action
  >>= fun actual_ids ->
  (ax >>= (fun (acc, seen) ->
       LibraryReader.return
         ((actual_ids, reason, preserve, seen)::acc,
          (StringPool.union actual_ids seen))))

let plan_interpret ax =
  List.map
    (fun (ids, reason, preserve, seen) ->
       StringPool.elements (StringPool.diff ids seen), reason, preserve)
    (fst ax)
  |> List.map
    (fun (ids, reason, preserve) -> List.map
        (fun x ->
           LibraryReader.bind
             (LibraryReader.description x)
             (fun descr -> LibraryReader.return (descr, reason, preserve)))
        ids)
  |> List.concat
  |> LibraryReader.dist

let plan policy env =
  let open LibraryReader.Infix in
  let prog =
    LibraryReader.leaves
    >>= plan_predicate_matching policy
    >>= List.fold_left plan_integrate (LibraryReader.return ([], StringPool.empty))
    >>= plan_interpret
  in
  LibraryReader.run env prog

let rmi descr =
  let image_refs =
    match descr.name with
    | [] -> [descr.image.Rashell_Docker_t.image_id]
    | lst -> List.map (fun (repository, tag) -> repository ^ ":" ^ tag) lst
  in
  Rashell_Docker.rmi image_refs

let exec plan =
  Lwt.catch
    (fun () -> Lwt_list.iter_s rmi (filtermap (fun (descr, _, flag) -> if flag then None else Some(descr)) plan))
    (function
      | Rashell_Command.Error(cmd, Unix.WEXITED 1, mesg) ->
          Lwt.fail_with mesg
      | exn -> Lwt.fail exn)
