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

(** An "easy" interface on top of the [Xmlm] library.  This version provides
    more convenient (but far less flexible) input and output functions that
    go to and from [string] values.  This avoids the need to write signal code,
    which is useful for quick scripts that manipulate XML.
   
    More advanced users should go straight to the [Xmlm] library and use it
    directly, rather than be saddled with the Ezxmlm interface below.
  *)

(**  {1 Basic types } *)

(** The type of a single XML tag *)
type node = ('a Xmlm.frag as 'a) Xmlm.frag

(** The type of a list of XML tags *)
type nodes = node list

(** Raised by the query combinators *)
exception Tag_not_found of string

(**  {1 Reading XML values } *)

(** Read an XML document from an [in_channel] *)
val from_channel : in_channel -> Xmlm.dtd * nodes

(** Read an XML document directly from a [string] *)
val from_string : string -> Xmlm.dtd * nodes

(** Low-level function to read directly from an [Xmlm] input source *)
val from_input : Xmlm.input -> Xmlm.dtd * node

(** {1 Writing XML values } *)

(** Write an XML document to an [out_channel] *)
val to_channel : out_channel -> Xmlm.dtd -> nodes -> unit

(** Write an XML document to a [string].  This goes via an intermediate
    [Buffer] and so may be slow on large documents. *)
val to_string : Xmlm.dtd -> nodes -> string

(** Low-level function to write directly to an [Xmlm] output source *)
val to_output : Xmlm.output -> Xmlm.dtd * node -> unit

(** {1 Selectors and utility functions } *)

(** Make a tag given a [tag] name and body [nodes] and an optional attribute list *)
val mk_tag : ?attrs:(string * string) list -> tag:string -> nodes -> node

(** Convert a list of [`Data] fragments to a human-readable string.  Any elements
    within the list are ignored, and multiple [`Data] fragments are concatenated. *)
val data_to_string : nodes -> string

(** Extracts the immediate subnodes that match the given [tag] name and return
    a tuple of the attributes associated with that tag and its child nodes. *)
val members_with_attr : string -> nodes -> (Xmlm.attribute list * nodes) list

(** Extracts the immediate subnodes that match the given [tag] name, and only return
    the contents of those tags (ignoring the attributes, which can be retrieved via
    the [members_with_attr] function *)
val members : string -> nodes -> nodes list

(** Extracts the first subnode that match the given [tag] name, and raises
    [Tag_not_found] if it can't find it. *)
val member_with_attr : string -> nodes -> Xmlm.attribute list * nodes

(** Extracts the first subnode that match the given [tag] name, and raises
    [Tag_not_found] if it can't find it. Only the contents of the tag are
    returned (ignoring the attributes, which can be retrieved via the
    [member_with_attr] function instead *)
val member : string -> nodes -> nodes

(** Traverses XML nodes and applies [f] to any tags that match the [tag] parameter.
    The result of the transformations is returned as a new set of nodes. *)
val filter_map : tag:string -> f:(Xmlm.attribute list -> nodes -> nodes) -> nodes -> nodes

(** Traverses XML nodes and applies [f] to any tags that match the [tag] parameter. *)
val filter_iter : tag:string -> f:(Xmlm.attribute list -> nodes -> unit) -> nodes -> unit

