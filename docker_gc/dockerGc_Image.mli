(* DockerGc_Image -- Docker GC Image

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)

type image = Rashell_Docker_t.image
(** The type of docker images. *)

type image_id = string
(** The type of image ids. *)

type repository = string
(** The type of image repositories. *)

type tag = string
(** The type of tags. *)

type description = {
  image: image;
  name: (repository * tag) list;
}
(** The type of descriptions for the item found in the local libray. *)

type policy = DockerGc_Policy.t
(** The type of garbage collection policies. *)

type predicate = DockerGc_Policy.predicate
(** The type of predicates for garbage collection polcies. *)

val list : unit -> (image_id * description) list Lwt.t
(** Return the contents of the local images library. *)

val plan : policy -> (image_id * description) list -> (image_id * string * bool) list
(** Apply the policy to some library contents.  The result mentions
    each leaf image id, the predicate that matched it, and if the image is
    to be preserved. *)

val exec : (image_id * string * bool) list -> unit Lwt.t
(** Apply the given plan by removing marked images. *)
