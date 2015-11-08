(* DockerGc_Policy -- Docker GC Policy specification

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)

type t =
  (predicate * action) list
and predicate =
  | True		(** Select all images. *)
  | False		(** Select no images. *)
  | Age of int		(** Select images whose age is at least the given number of days. *)
  | Repository of string(** Select images belonging to the given repository. *)
  | Dandling		(** Select dandling images. *)
  | And of predicate * predicate
  | Or of predicate * predicate
  | Not of predicate
and action =
  | Delete		(** Delete selected images. *)
  | PreserveAll		(** Preserve all selected images. *)
  | PreserveRecent of int (** Preserver at most the given number of selected images. *)

val pp_print_predicate : Format.formatter -> predicate -> unit
(** Pretty-print the given predicate. *)

val predicate_to_string : predicate -> string
(** Convert a predicate to a string. *)

val predicate_of_string : string -> predicate
(** Parse a string to build a predicate.

@raise Failure when the string cannot be correctly parsed. *)

val pp_print_action : Format.formatter -> action -> unit
(** Pretty-print the given action. *)

val action_to_string : action -> string
(** Convert an action to a string. *)

val action_of_string : string -> action
(** Parse a string to build an action.

@raise Failure when the string cannot be correctly parsed. *)

val from_file : string -> t
(** Read a policy from a JSON file.  This is an example of a valid file:

{v
Dandling                            : Delete
Not(Age(3))                         : PreserveAll
Repository("organisation/repo")     : PreserveRecent(3)
True                                : Delete
v} *)
