(*
 * Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

type node = ('a Xmlm.frag as 'a) Xmlm.frag
type nodes = node list

let from_input i =
  try
    let el tag children = `El (tag, children) in
    let data d = `Data d in
    Xmlm.input_doc_tree ~el ~data i
  with Xmlm.Error((line,col),err) ->
    let err = Xmlm.error_message err in
    raise (Failure (Printf.sprintf "[line %d, col %d] %s" line col err))

let from_channel chan =
  let i = Xmlm.make_input (`Channel chan) in
  let (dtd,doc) = from_input i in
  (dtd, [doc])

let from_string buf =
  let i = Xmlm.make_input (`String (0,buf)) in
  let (dtd,doc) = from_input i in
  (dtd, [doc])
  
let to_output o t = 
  let frag = function
  | `El (tag, childs) -> `El (tag, childs) 
  | `Data d -> `Data d in
  Xmlm.output_doc_tree frag o t

let write_document mode dtd doc =
  let o = Xmlm.make_output ~decl:false mode in
  match doc with
  | [] -> ()
  | hd::tl ->
     to_output o (dtd, hd);
     List.iter (fun t -> to_output o (None, t)) tl

let to_channel chan dtd doc =
  write_document (`Channel chan) dtd doc

let to_string dtd doc =
  let buf = Buffer.create 512 in
  write_document (`Buffer buf) dtd doc;
  Buffer.contents buf

let mk_tag ?(attrs=[]) ~tag (contents:nodes) : node =
  let attrs = List.map (fun (k,v) -> ("",k),v) attrs in
  let tag = ("", tag), attrs in
  `El (tag, contents)

let rec filter_map ~tag ~f i =
  List.concat (
    List.map (
      function
      | `El ((("",t),attr),c) when t=tag -> f attr c
      | `El (p,c) -> [`El (p, (filter_map ~tag ~f c))]
      | `Data x -> [`Data x]
    ) i
  )

let rec filter_iter ~tag ~f i =
  List.iter (
    function
    | `El ((("",t),attr),c) when t=tag -> f attr c
    | `El (_,c) -> filter_iter ~tag ~f c
    | `Data _ -> ()
  ) i
