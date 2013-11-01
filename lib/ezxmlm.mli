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

(**  {1 Reading XML values } *)

(** Read an XML document from an [in_channel] *)
val from_channel : in_channel -> Xmlm.dtd * nodes

(** Read an XML document directly from a [string] *)
val from_string  : string -> Xmlm.dtd * nodes

(** Low-level function to read directly from an [Xmlm] input source *)
val from_input   : Xmlm.input -> Xmlm.dtd * node

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

(** Traverses XML nodes and applies [f] to any tags that match the [tag] parameter.
    The result of the transformations is returned as a new set of nodes. *)
val filter_map  : tag:string -> f:(Xmlm.attribute list -> nodes -> nodes) -> nodes -> nodes

(** Traverses XML nodes and applies [f] to any tags that match the [tag] parameter. *)
val filter_iter : tag:string -> f:(Xmlm.attribute list -> nodes -> unit) -> nodes -> unit
