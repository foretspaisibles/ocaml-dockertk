open Printf
open Lwt.Infix
open Rashell_Docker_t
open DockerGc_Configuration

module StringPool =
  Set.Make(String)

module Application =
  Gasoline_Plain_SecureTool

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

module Component_Policy =
struct
  let comp = Application.Component.make
      ~name:"policy"
      ~description:"Policy for deleting docker images"
      ()

  module Configuration =
  struct
    open Application.Configuration

    let file =
      make_string comp ~flag:'f'
        "file"
        (try sprintf "%s/.docker/docker_gc.conf" (Sys.getenv "HOME")
         with Not_found -> sprintf "%s/docker/docker_gc.conf" ac_dir_sysconfdir)
        "Path to the policy file"
  end

  let policy () =
    try DockerGc_Policy.from_file (Configuration.file())
    with Sys_error(_) -> DockerGc_Policy.[
        Dandling, Delete;
        True, PreserveAll;
      ]
end


module Component_Plan =
struct

  let comp = Application.Component.make
      ~name:"plan"
      ~description:"Processing plan for deleting docker images and containers"
      ()

  module Configuration =
  struct
    open Application.Configuration

    let dry_run =
      make_bool comp ~optarg:"true" ~flag:'n'
        "#dry_run" false
        "Dry run, only list actions to be taken without executing them"

    let _verbose =
      make_bool comp ~optarg:"true" ~flag:'v'
        "#verbose" false
        "Verbose, list the matching predicate with each action taken"

    let verbose () =
      _verbose () || dry_run ()
  end

  let process policy =
    let log_plan =
      if Configuration.verbose () then
        (fun (id, reason, preserve) ->
           Lwt_io.eprintf "%8s %s %s\n"
             (if preserve then "Preserve" else "Delete")
             id
             reason)
      else
        (fun _ -> Lwt.return_unit)
    in
    let snoop plan =
      Lwt_list.iter_s log_plan plan
      >>= fun () -> Lwt.return plan
    in
    let containers () =
      DockerGc_Container.list ()
      >|= DockerGc_Container.plan
      >>= snoop
      >>= DockerGc_Container.exec
    in
    let images () =
      DockerGc_Image.list ()
      >|= DockerGc_Image.plan policy
      >>= snoop
      >>= DockerGc_Image.exec
    in
    containers () >>= images
end

module Component_Main =
struct
  let comp =
    Application.Component.make
      ~name:"main"
      ~description:"Main component"
      ()


  module Configuration =
  struct
    open Application.Configuration

  end


  let run _ =
    Lwt_main.run
      (Component_Plan.process (Component_Policy.policy()))
end

let () =
  let open Application.Configuration in
  Application.run "docker_gc"
    "[-hnv]"
    "Remove obsolete containers and images"
    Component_Main.run