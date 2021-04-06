open Preface_core.Fun

module Core (Req : Preface_specs.Traversable.WITH_TRAVERSE) :
  Preface_specs.Traversable.CORE
    with type 'a t = 'a Req.t
     and type 'a iter = 'a Req.iter =
  Req

module Core_over_applicative
    (A : Preface_specs.APPLICATIVE)
    (Req : Preface_specs.Traversable.WITH_TRAVERSE with type 'a t = 'a A.t) :
  Preface_specs.Traversable.CORE
    with type 'a t = 'a Req.t
     and type 'a iter = 'a Req.iter =
  Core (Req)

module Core_over_monad
    (M : Preface_specs.MONAD)
    (Req : Preface_specs.Traversable.CORE with type 'a t = 'a M.t) :
  Preface_specs.Traversable.CORE
    with type 'a t = 'a Req.t
     and type 'a iter = 'a Req.iter =
  Core (Req)

module Operation (C : Preface_specs.Traversable.CORE) :
  Preface_specs.Traversable.OPERATION
    with type 'a t = 'a C.t
     and type 'a iter = 'a C.iter = struct
  type 'a t = 'a C.t

  type 'a iter = 'a C.iter

  let sequence x = C.traverse id x
end

module Via
    (C : Preface_specs.Traversable.CORE)
    (O : Preface_specs.Traversable.OPERATION
           with type 'a t = 'a C.t
            and type 'a iter = 'a C.iter) :
  Preface_specs.TRAVERSABLE with type 'a t = 'a C.t and type 'a iter = 'a C.iter =
struct
  include C
  include O
end

module Over_applicative
    (A : Preface_specs.APPLICATIVE)
    (Req : Preface_specs.Traversable.WITH_TRAVERSE with type 'a t = 'a A.t) :
  Preface_specs.TRAVERSABLE
    with type 'a t = 'a Req.t
     and type 'a iter = 'a Req.iter = struct
  module Core = Core_over_applicative (A) (Req)
  module Operation = Operation (Core)
  include Core
  include Operation
end

module Over_monad
    (M : Preface_specs.MONAD)
    (Req : Preface_specs.Traversable.WITH_TRAVERSE with type 'a t = 'a M.t) :
  Preface_specs.TRAVERSABLE
    with type 'a t = 'a Req.t
     and type 'a iter = 'a Req.iter = struct
  module Core = Core_over_monad (M) (Req)
  module Operation = Operation (Core)
  include Core
  include Operation
end

module Join_with_monad
    (I : Preface_specs.MONAD) (T : functor (M : Preface_specs.MONAD) ->
      Preface_specs.TRAVERSABLE
        with type 'a t = 'a M.t
         and type 'a iter = 'a I.t) :
  Preface_specs.Traversable.API_OVER_MONAD with type 'a t = 'a I.t = struct
  module Traversable = T
  include I
end

module Join_with_applicative
    (I : Preface_specs.APPLICATIVE)
    (T : functor
      (A : Preface_specs.APPLICATIVE)
      ->
      Preface_specs.TRAVERSABLE
        with type 'a t = 'a A.t
         and type 'a iter = 'a I.t) :
  Preface_specs.Traversable.API_OVER_APPLICATIVE with type 'a t = 'a I.t =
struct
  module Traversable = T
  include I
end
