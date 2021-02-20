open Preface_core.Fun

module Core_over_functor
    (Functor : Preface_specs.Functor.CORE)
    (Select : Preface_specs.Selective.CORE_WITH_PURE_AND_SELECT
                with type 'a t = 'a Functor.t) :
  Preface_specs.Selective.CORE with type 'a t = 'a Functor.t = struct
  include Functor
  include Select

  module Ap = struct
    type nonrec 'a t = 'a t

    let pure x = pure x

    let apply f x = select (map Either.left f) (map ( |> ) x)
  end

  include Applicative.Core_via_apply (Ap)
end

module Core_over_applicative
    (Applicative : Preface_specs.APPLICATIVE)
    (Select : Preface_specs.Selective.CORE_WITH_SELECT
                with type 'a t = 'a Applicative.t) :
  Preface_specs.Selective.CORE with type 'a t = 'a Applicative.t = struct
  include Applicative
  include Select
end

module Operation (Core : Preface_specs.Selective.CORE) :
  Preface_specs.Selective.OPERATION with type 'a t = 'a Core.t = struct
  include Applicative.Operation (Core)

  let branch s l r =
    let open Core in
    let a = map Either.(map_right left) s
    and b = map (compose_right_to_left Either.right) l in
    select (select a b) r
  ;;

  let if_ predicate if_true unless =
    let open Core in
    branch
      (map (fun b -> Either.(if b then left () else right ())) predicate)
      (map constant if_true) (map constant unless)
  ;;

  let bind_bool x f = if_ x (f false) (f true)

  let when_ predicate action = if_ predicate action (Core.pure ())

  let or_ left right = if_ left (Core.pure true) right

  let and_ left right = if_ left right (Core.pure false)

  let exists predicate =
    let rec aux_exists = function
      | [] -> Core.pure false
      | x :: xs -> if_ (predicate x) (Core.pure true) (aux_exists xs)
    in
    aux_exists
  ;;

  let for_all predicate =
    let rec aux_for_all = function
      | [] -> Core.pure true
      | x :: xs -> if_ (predicate x) (aux_for_all xs) (Core.pure false)
    in
    aux_for_all
  ;;

  let rec while_ action = when_ action (while_ action)
end

module Infix
    (Core : Preface_specs.Selective.CORE)
    (Operation : Preface_specs.Selective.OPERATION with type 'a t = 'a Core.t) :
  Preface_specs.Selective.INFIX with type 'a t = 'a Core.t = struct
  include Applicative.Infix (Core) (Operation)

  let ( <*? ) e f = Core.select e f

  let ( <||> ) l r = Operation.or_ l r

  let ( <&&> ) l r = Operation.and_ l r
end

module Syntax (Core : Preface_specs.Selective.CORE) :
  Preface_specs.Selective.SYNTAX with type 'a t = 'a Core.t = struct
  include Applicative.Syntax (Core)
end

module Via
    (Core : Preface_specs.Selective.CORE)
    (Operation : Preface_specs.Selective.OPERATION with type 'a t = 'a Core.t)
    (Infix : Preface_specs.Selective.INFIX with type 'a t = 'a Core.t)
    (Syntax : Preface_specs.Selective.SYNTAX with type 'a t = 'a Core.t) :
  Preface_specs.SELECTIVE with type 'a t = 'a Core.t = struct
  include Core
  include Operation
  include Syntax
  include Infix
  module Infix = Infix
  module Syntax = Syntax
end

module Over_functor
    (Functor : Preface_specs.Functor.CORE)
    (Select : Preface_specs.Selective.CORE_WITH_PURE_AND_SELECT
                with type 'a t = 'a Functor.t) :
  Preface_specs.SELECTIVE with type 'a t = 'a Select.t = struct
  module Core = Core_over_functor (Functor) (Select)
  module Operation = Operation (Core)
  module Infix = Infix (Core) (Operation)
  module Syntax = Syntax (Core)
  include Core
  include Operation
  include Infix
  include Syntax
end

module Over_applicative
    (Applicative : Preface_specs.APPLICATIVE)
    (Select : Preface_specs.Selective.CORE_WITH_SELECT
                with type 'a t = 'a Applicative.t) :
  Preface_specs.SELECTIVE with type 'a t = 'a Select.t = struct
  module Core = Core_over_applicative (Applicative) (Select)
  module Operation = Operation (Core)
  module Infix = Infix (Core) (Operation)
  module Syntax = Syntax (Core)
  include Core
  include Operation
  include Infix
  include Syntax
end

module Select_from_monad (Monad : Preface_specs.MONAD) :
  Preface_specs.Selective.CORE_WITH_SELECT with type 'a t = 'a Monad.t = struct
  type 'a t = 'a Monad.t

  let pure x = Monad.return x

  let select xs fs =
    let open Monad.Infix in
    xs >>= Preface_core.Shims.Either.case (fun a -> fs >|= (fun f -> f a)) pure
  ;;
end
