(* DockerGc_Policy -- Docker GC Policy specification

   Docker Toolkit (https://github.com/michipili/dockertk)
   This file is part of Docker Toolkit

   Copyright © 2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)
open Printf

type t =
  (predicate * action) list
and predicate =
  | True
  | False
  | Age of int
  | Repository of string
  | Dandling
  | And of predicate * predicate
  | Or of predicate * predicate
  | Not of predicate
and action =
  | Delete
  | PreserveAll
  | PreserveRecent of int

let rec pp_print_predicate ppt =
  let open Format in
  function
  | True -> fprintf ppt "True"
  | False -> fprintf ppt "False"
  | And(a,b) -> fprintf ppt "And(%a, %a)" pp_print_predicate a pp_print_predicate b
  | Or(a,b) -> fprintf ppt "Or(%a, %a)" pp_print_predicate a pp_print_predicate b
  | Not(a) -> fprintf ppt "Not(%a)" pp_print_predicate a
  | Age(n) -> fprintf ppt "Age(%d)" n
  | Repository(name) -> fprintf ppt "Repository(%S)" name
  | Dandling -> fprintf ppt "Dandling"

module PredicateFormatBasis =
struct
  type t = predicate
  let pp_print = pp_print_predicate
end

module PredicateFormatMethods =
  Mixture_Format.Make(PredicateFormatBasis)

let predicate_to_string =
  PredicateFormatMethods.to_string

let pp_print_action fft =
  let open Format in
  function
  | Delete -> pp_print_string fft "Delete"
  | PreserveAll -> pp_print_string fft "PreserveAll"
  | PreserveRecent(n) -> fprintf fft "PreserveRecent(%d)" n

module ActionFormatBasis =
struct
  type t = action
  let pp_print = pp_print_action
end

module ActionFormatMethods =
  Mixture_Format.Make(ActionFormatBasis)

let action_to_string =
  ActionFormatMethods.to_string


type token =
  | TRUE
  | FALSE
  | AGE
  | REPOSITORY
  | DANDLING
  | AND
  | OR
  | NOT
  | DELETE
  | PRESERVE_ALL
  | PRESERVE_RECENT
  | COMMA
  | LPAREN
  | RPAREN
  | IDENT of string
  | INTEGER of int

let table = [
  "True", TRUE;
  "False", FALSE;
  "Age", AGE;
  "Repository", REPOSITORY;
  "Dandling", DANDLING;
  "And", AND;
  "Or", OR;
  "Not", NOT;
  "Delete", DELETE;
  "PreserveAll", PRESERVE_ALL;
  "PreserveRecent", PRESERVE_RECENT;
  ",", COMMA;
  "(", LPAREN;
  ")", RPAREN;
]

let stream_elements s =
  let rec loop ax =
    match Stream.peek s with
    | Some(x) -> (Stream.junk s; loop (x :: ax))
    | None -> List.rev ax
  in
  loop []

let lexer s =
  Stream.of_string s
  |> Genlex.make_lexer (List.map fst table)
  |> stream_elements
  |> List.map
    (let open Genlex in function
        | Kwd keyword ->
            (try List.assoc keyword table
             with Not_found ->
               ksprintf failwith "DockerGc_Policy.lexer: %S: Not a keyword." keyword)
        | Ident(s) -> IDENT(s)
        | Int(n) -> INTEGER(n)
        | String(s) -> IDENT(s)
        | Float(_)
        | Char(_) -> failwith "DockerGc_Policy.lexer: Unexpected tokens.")

let paren_split toks0 =
  let rec loop acc n toks =
    match n, toks with
    | 0, RPAREN :: _ ->
        failwith "DockerGc_Policy.parser: Unbalanced parenthesis."
    | 1, RPAREN :: tl -> (List.rev acc, tl)
    | _, RPAREN :: tl -> loop (RPAREN :: acc) (n-1) tl
    | _, LPAREN :: tl -> loop (LPAREN :: acc) (n+1) tl
    | _, hd :: tl -> loop (hd :: acc) n tl
    | _, [] ->
        failwith "DockerGc_Policy.parser: Unbalanced parenthesis."
  in
  loop [] 1 toks0

let rec read_argv_loop argv acc n toks =
  match n, toks with
  | 0, RPAREN :: _ ->
      failwith "DockerGc_Policy.parser: Unbalanced parenthesis."
  | 1, RPAREN :: [] -> List.rev ((List.rev acc) :: argv)
  | 1, RPAREN :: _ ->
      failwith "DockerGc_Policy.parser: Unexpected tokens after arguments."
  | _, RPAREN :: tl -> read_argv_loop argv (RPAREN :: acc) (n-1) tl
  | _, LPAREN :: tl -> read_argv_loop argv (LPAREN :: acc) (n+1) tl
  | 1, COMMA :: tl -> read_argv_loop ((List.rev acc) :: argv) [] 1 tl
  | _, hd :: tl -> read_argv_loop argv (hd :: acc) n tl
  | _, [] ->
      failwith "DockerGc_Policy.parser: Unbalanced parenthesis."

let read_argv toks0 =
  read_argv_loop [] [] 1 toks0

let id x =
    x

let failwith_arity s =
  ksprintf failwith
    "DockerGc_Policy.parser: %s: Incorrect number of arguments." s

let rec predicate_entry cont =
  function
  | [] -> failwith "DockerGc_Policy.parser: Unexpected end of input."
  | TRUE :: [] -> True
  | FALSE :: [] -> False
  | AGE :: LPAREN :: INTEGER(n) :: RPAREN :: [] -> Age(n)
  | REPOSITORY :: LPAREN :: IDENT(s) :: RPAREN :: [] -> Repository(s)
  | DANDLING :: [] -> Dandling
  | NOT :: LPAREN :: tl ->
      (match read_argv tl with
       | [a] -> cont (predicate_entry (fun x -> Not(x)) a)
       | _ -> failwith_arity "Not")
  | AND :: LPAREN :: tl ->
      (match read_argv tl with
       | [a; b] -> cont (And(predicate_entry id a, predicate_entry id b))
       | _ -> failwith_arity "And")
  | OR :: LPAREN :: tl ->
      (match read_argv tl with
       | [a; b] -> cont (Or(predicate_entry id a, predicate_entry id b))
       | _ -> failwith_arity "Or")
  | _ -> failwith "DockerGc_Policy.parser: Syntax error."

let predicate_of_string s =
  predicate_entry id (lexer s)

let action_entry cont =
  function
  | [] -> failwith "DockerGc_Policy.parser: Unexpected end of input."
  | DELETE :: [] -> cont Delete
  | PRESERVE_ALL :: [] -> cont PreserveAll
  | PRESERVE_RECENT :: LPAREN :: INTEGER(n) :: RPAREN :: [] ->
      cont(PreserveRecent(n))
  | _ -> failwith "DockerGc_Policy.parser: Syntax error."

let action_of_string s =
  action_entry id (lexer s)

let lines_from_file s =
  let c = open_in s in
  let next_line () =
    try Some(input_line c)
    with End_of_file -> (close_in c; None)
  in
  let rec loop acc =
    match next_line () with
    | Some(s) -> loop (s :: acc)
    | None -> List.rev acc
  in
  loop []

let from_file s =
  let open Str in
  let declaration_re = regexp "\\([^:]*\\)[\t ]*:[\t ]*\\(.*\\)" in
  let ignore_re = regexp "^#\\|^$" in
  let rec loop acc line =
    if string_match ignore_re line 0 then
      acc
    else if string_match declaration_re line 0 then
      (predicate_of_string (matched_group 1 line),
       action_of_string (matched_group 2 line)) :: acc
    else
      ksprintf failwith "DockerGc_Policy.from_file: %S: Syntax error." line
  in
  List.fold_left loop [] (lines_from_file s)
  |> List.rev
