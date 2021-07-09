open Preface_core.Fun

module Core_via_divide_and_conquer
    (Req : Preface_specs.Divisible.WITH_DIVIDE_AND_CONQUER) :
  Preface_specs.Divisible.CORE with type 'a t = 'a Req.t = struct
  include Req

  let contramap f x = (divide ((fun x -> ((), x)) % f) conquer) x
end

module Core_via_contramap_and_divide_and_conquer
    (Req : Preface_specs.Divisible.WITH_CONTRAMAP_AND_DIVIDE_AND_CONQUER) :
  Preface_specs.Divisible.CORE with type 'a t = 'a Req.t =
  Req

module Operation (Core : Preface_specs.Divisible.CORE) :
  Preface_specs.Divisible.OPERATION with type 'a t = 'a Core.t = struct
  include Contravariant.Operation (Core)

  let divided x = Core.divide id x

  let conquered = Core.conquer
end

module Infix = Contravariant.Infix

module Via
    (Core : Preface_specs.Divisible.CORE)
    (Operation : Preface_specs.Divisible.OPERATION with type 'a t = 'a Core.t)
    (Infix : Preface_specs.Divisible.INFIX with type 'a t = 'a Operation.t) :
  Preface_specs.DIVISIBLE with type 'a t = 'a Infix.t = struct
  include Core
  include Operation
  include Infix
  module Infix = Infix
end

module Via_divide_and_conquer
    (Req : Preface_specs.Divisible.WITH_DIVIDE_AND_CONQUER) :
  Preface_specs.DIVISIBLE with type 'a t = 'a Req.t = struct
  module Core = Core_via_divide_and_conquer (Req)
  include Core
  module Operation = Operation (Core)
  include Operation
  module Infix = Infix (Core) (Operation)
  include Infix
end

module Via_contramap_and_divide_and_conquer
    (Req : Preface_specs.Divisible.WITH_CONTRAMAP_AND_DIVIDE_AND_CONQUER) :
  Preface_specs.DIVISIBLE with type 'a t = 'a Req.t = struct
  module Core = Core_via_contramap_and_divide_and_conquer (Req)
  include Core
  module Operation = Operation (Core)
  include Operation
  module Infix = Infix (Core) (Operation)
  include Infix
end

module Over_contravariant
    (Contravariant : Preface_specs.Contravariant.CORE)
    (Req : Preface_specs.Divisible.WITH_DIVIDE_AND_CONQUER
             with type 'a t = 'a Contravariant.t) :
  Preface_specs.DIVISIBLE with type 'a t = 'a Req.t =
Via_contramap_and_divide_and_conquer (struct
  include Req

  let contramap = Contravariant.contramap
end)
