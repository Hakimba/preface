(** A [Comonad] is the dual of the {!module:Monad}. *)

(** {2 Laws}

    - [extend extract = id]
    - [(extend %> extract) f = f]
    - [extend g %> extend f = extend (extend g %> f)]
    - [f =>= extract = f]
    - [extract =>= f = f]
    - [(f =>= g) =>= h = f =>= (g =>= h)]
    - [extract <% duplicate = id]
    - [fmap extract <% duplicate = id]
    - [duplicate %> duplicate = fmap duplicate <% duplicate]
    - [extend f = fmap f <% duplicate]
    - [duplicate = extend id]
    - [fmap f = extend (f <% extract)] *)

(** {1 Minimal definition} *)

(** Minimal definition using [extract], [map] and [duplicate]. *)
module type WITH_MAP_AND_DUPLICATE = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val extract : 'a t -> 'a
  (** Extract a ['a] from ['a t]. Dual of return. *)

  val duplicate : 'a t -> 'a t t
  (** Dual of join. *)

  val map : ('a -> 'b) -> 'a t -> 'b t
  (** Mapping over from ['a] to ['b] over ['a t] to ['b t]. *)
end

(** Minimal definition using [extract] and [extend]. *)
module type WITH_EXTEND = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val extract : 'a t -> 'a
  (** Extract a ['a] from ['a t]. Dual of return. *)

  val extend : ('a t -> 'b) -> 'a t -> 'b t
  (** Dual of bind. *)
end

(** Minimal definition using [extract] and [compose_left_to_right]. *)
module type WITH_COKLEISLI_COMPOSITION = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val extract : 'a t -> 'a
  (** Extract a ['a] from ['a t]. Dual of return. *)

  val compose_left_to_right : ('a t -> 'b) -> ('b t -> 'c) -> 'a t -> 'c
  (** Composing monadic functions using Co-Kleisli Arrow (from left to right). *)
end

(** {1 Structure anatomy} *)

(** Basis operations. *)
module type CORE = sig
  include WITH_MAP_AND_DUPLICATE
  (** @inline *)

  include WITH_EXTEND with type 'a t := 'a t
  (** @inline *)

  include WITH_COKLEISLI_COMPOSITION with type 'a t := 'a t
  (** @inline *)
end

(** Additional operations. *)
module type OPERATION = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val lift : ('a -> 'b) -> 'a t -> 'b t
  (** Mapping over from ['a] to ['b] over ['a t] to ['b t]. *)

  val lift2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
  (** Mapping over from ['a] and ['b] to ['c] over ['a t] and ['b t] to ['c t]. *)

  val lift3 : ('a -> 'b -> 'c -> 'd) -> 'a t -> 'b t -> 'c t -> 'd t
  (** Mapping over from ['a] and ['b] and ['c] to ['d] over ['a t] and ['b t]
      and ['c t] to ['d t]. *)

  val compose_right_to_left : ('b t -> 'c) -> ('a t -> 'b) -> 'a t -> 'c
  (** Composing comonadic functions using Co-Kleisli Arrow (from right to left). *)

  include Functor.OPERATION with type 'a t := 'a t
  (** @inline *)
end

(** Syntax extensions. *)
module type SYNTAX = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val ( let@ ) : 'a t -> ('a t -> 'b) -> 'b t
  (** Syntaxic shortcuts for version of {!val:CORE.extend}:

      [let@ x = e in f] is equals to [extend f e]. *)

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  (** Syntaxic shortcuts for version of {!val:CORE.map} *)
end

(** Infix operators. *)
module type INFIX = sig
  type 'a t
  (** The type held by the [Comonad]. *)

  val ( =>> ) : 'a t -> ('a t -> 'b) -> 'b t
  (** Infix flipped version of {!val:CORE.extend}. *)

  val ( <<= ) : ('a t -> 'b) -> 'a t -> 'b t
  (** Infix version of {!val:CORE.extend}. *)

  val ( =>= ) : ('a t -> 'b) -> ('b t -> 'c) -> 'a t -> 'c
  (** Infix version of {!val:CORE.compose_left_to_right}. *)

  val ( =<= ) : ('b t -> 'c) -> ('a t -> 'b) -> 'a t -> 'c
  (** Infix version of {!val:OPERATION.compose_right_to_left}. *)

  val ( <@@> ) : 'a t -> ('a -> 'b) t -> 'b t
  (** Applicative functor of [('a -> 'b) t] over ['a t] to ['b t]. *)

  val ( <@> ) : ('a -> 'b) t -> 'a t -> 'b t
  (** Applicative functor of [('a -> 'b) t] over ['a t] to ['b t]. *)

  val ( @> ) : unit t -> 'b t -> 'b t
  (** Discard the value of the first argument. *)

  val ( <@ ) : 'a t -> unit t -> 'a t
  (** Discard the value of the second argument. *)

  include Functor.INFIX with type 'a t := 'a t
  (** @inline *)
end

(** {1 Complete API} *)

(** The complete interface of a [Comonad]. *)
module type API = sig
  (** {1 Type} *)

  type 'a t
  (** The type held by the [Comonad]. *)

  (** {1 Functions} *)

  include CORE with type 'a t := 'a t
  (** @inline *)

  include OPERATION with type 'a t := 'a t
  (** @inline *)

  (** {1 Infix operators} *)

  module Infix : INFIX with type 'a t := 'a t

  include module type of Infix
  (** @inline *)

  (** {1 Syntax} *)

  module Syntax : SYNTAX with type 'a t := 'a t

  include module type of Syntax
  (** @inline *)
end

(** {1 Additional interfaces} *)

(** {2 Transformer}

    A standard representation of a comonad transformer. (It is likely that not
    all transformers respect this interface) *)

module type TRANSFORMER = sig
  type 'a comonad
  (** The inner comonad. *)

  type 'a t
  (** The type held by the comonad transformer.*)

  val lower : 'a t -> 'a comonad
  (** get the underlying comonad. *)
end
