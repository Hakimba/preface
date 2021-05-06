(** A [Free applicative] allows you to build an
    {!module:Preface_specs.Applicative} from a given
    {!module:Preface_specs.Functor}. *)

(** Such {!module:Preface_specs.Applicative} is equiped with and additional
    function for [promoting] values from the underlying
    {!module:Preface_specs.Functor} into the [Free applicative] and a
    [Natural transformations] for transforming the value of the
    [Free applicative] to an other {!module:Preface_specs.Applicative} or to a
    {!module:Preface_specs.Monoid}. *)

(** {2 Note about complexity}

    Although free constructs are elegant, they introduce an execution cost due
    to the recursive nature of defining the type of a [Free Applicative]. There
    are {e cheaper} encodings but they are not, for the moment, available in
    Preface. *)

(** {1 Structure anatomy} *)

(** The natural transformation for [Free Applicative] to [Applicative]. *)
module type TO_APPLICATIVE = sig
  type 'a t
  (** The type held by the [Free applicative]. *)

  type 'a f
  (** The type held by the {!module:Preface_specs.Functor}. *)

  type 'a applicative
  (** The type held by the [Applicative]. *)

  type natural_transformation = { transform : 'a. 'a f -> 'a applicative }

  val run : natural_transformation -> 'a t -> 'a applicative
  (** Run the natural transformation over the [Free applicative]. *)
end

(** The natural transformation for [Free Applicative] to [Monoid]. *)
module type TO_MONOID = sig
  type 'a t
  (** The type held by the [Free applicative]. *)

  type 'a f
  (** The type held by the {!module:Preface_specs.Functor}. *)

  type monoid
  (** The type held by the [Monoid]. *)

  type natural_transformation = { transform : 'a. 'a f -> monoid }

  val run : natural_transformation -> 'a t -> monoid
  (** Run the natural transformation over the [Free applicative]. *)
end

(** The [Free applicative] API without the {!module:Preface_specs.Applicative}
    API. *)
module type CORE = sig
  type 'a f
  (** The type held by the {!module:Preface_specs.Functor}. *)

  (** The type held by the [Free applicative]. *)
  type _ t =
    | Pure : 'a -> 'a t
    | Apply : ('a -> 'b) t * 'a f -> 'b t

  val promote : 'a f -> 'a t
  (** Promote a value from the {!module:Preface_specs.Functor} into the
      [Free applicative]. *)

  (** The natural transformation from a [Free applicative] to an other
      {!module:Preface_specs.Applicative}. *)
  module To_applicative (Applicative : Applicative.CORE) :
    TO_APPLICATIVE
      with type 'a t := 'a t
       and type 'a f := 'a f
       and type 'a applicative := 'a Applicative.t

  (** The natural transformation from a [Free applicative] to a
      {!module:Preface_specs.Monoid}. *)
  module To_monoid (Monoid : Monoid.CORE) :
    TO_MONOID
      with type 'a t := 'a t
       and type 'a f := 'a f
       and type monoid := Monoid.t
end

(** {1 Complete API} *)

(** The complete interface of a [Free applicative]. *)
module type API = sig
  include CORE
  (** @inline *)

  (** {1 Applicative API}

      A [Free applicative] is also an {!module:Preface_specs.Applicative}. *)

  include Applicative.API with type 'a t := 'a t
  (** @inline *)
end

(** {1 Additional references}

    - {{:https://arxiv.org/pdf/1403.0749.pdf} Free Applicative Functors} *)
