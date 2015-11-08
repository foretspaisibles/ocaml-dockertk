(* DockerGc_Container -- Docker GC Containers

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)
open Lwt.Infix
open Rashell_Docker_t

type container = Rashell_Docker_t.container

type container_id = string

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

let list () =
  Rashell_Docker.ps ()
  >|= List.map (fun container -> (container.container_id, container))

let plan lst =
  List.map (fun (container_id, container) ->
      let preserve =
        container.container_state.state_running
      in
      (container_id,
       (if preserve then "Running" else "Not(Running)"),
       preserve))
    lst

let exec plan =
  Lwt.catch
    (fun () -> Rashell_Docker.rmi
        (filtermap (fun (id, _, flag) -> if flag then None else Some(id)) plan))
    (function
      | Rashell_Command.Error(cmd, Unix.WEXITED 1, mesg) ->
          Lwt.fail_with mesg
      | exn -> Lwt.fail exn)
