(* DockerGc_Container -- Docker GC Containers

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)

type container = Rashell_Docker_t.container
(** The type of docker containers. *)

type container_id = string
(** The type of container ids. *)

val list : unit -> (container_id * container) list Lwt.t
(** Return the list of current containers. *)

val plan : (container_id * container) list -> (container_id * string * bool) list
(** Apply the built-in policy to mark each non-running container to be
    deleted. *)

val exec : (container_id * string * bool) list -> unit Lwt.t
(** Apply the given plan by removing marked containers. *)
