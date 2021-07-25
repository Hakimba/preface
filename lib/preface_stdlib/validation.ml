type ('a, 'errors) t =
  | Valid of 'a
  | Invalid of 'errors

let valid x = Valid x

let invalid errors = Invalid errors

let pure = valid

let case f g = function Valid x -> f x | Invalid x -> g x

module Bifunctor = Preface_make.Bifunctor.Via_bimap (struct
  type nonrec ('a, 'errors) t = ('a, 'errors) t

  let bimap f g = function Valid x -> Valid (f x) | Invalid x -> Invalid (g x)
end)

module Functor (T : Preface_specs.Types.T0) =
Preface_make.Functor.Via_map (struct
  type nonrec 'a t = ('a, T.t) t

  let map f = function Valid x -> Valid (f x) | Invalid err -> Invalid err
end)

let traverse_aux pure map f = function
  | Invalid x -> pure (Invalid x)
  | Valid x -> map (fun x -> Valid x) (f x)
;;

module Alt (Errors : Preface_specs.SEMIGROUP) =
  Preface_make.Alt.Over_functor
    (Functor
       (Errors))
       (struct
         type nonrec 'a t = ('a, Errors.t) t

         let combine a b =
           match (a, b) with
           | (Invalid _, result) -> result
           | (Valid x, _) -> Valid x
         ;;
       end)

module Applicative (Errors : Preface_specs.SEMIGROUP) = struct
  module A = Preface_make.Applicative.Via_apply (struct
    type nonrec 'a t = ('a, Errors.t) t

    let pure = valid

    let apply fx xs =
      match (fx, xs) with
      | (Valid f, Valid x) -> Valid (f x)
      | (Invalid left, Invalid right) -> Invalid (Errors.combine left right)
      | (Invalid x, _) | (_, Invalid x) -> Invalid x
    ;;
  end)

  module T (A : Preface_specs.APPLICATIVE) =
    Preface_make.Traversable.Over_applicative
      (A)
      (struct
        type 'a t = 'a A.t

        type 'a iter = ('a, Errors.t) Bifunctor.t

        let traverse f x = traverse_aux A.pure A.map f x
      end)

  include Preface_make.Traversable.Join_with_applicative (A) (T)
end

module Selective (Errors : Preface_specs.SEMIGROUP) = struct
  module A = Applicative (Errors)

  module S =
    Preface_make.Selective.Over_applicative_via_select
      (A)
      (struct
        type nonrec 'a t = ('a, Errors.t) t

        let select either f =
          let open Either in
          match either with
          | Valid (Left a) -> A.map (( |> ) a) f
          | Valid (Right b) -> Valid b
          | Invalid err -> Invalid err
        ;;
      end)

  include S
end

module Monad (T : Preface_specs.Types.T0) = struct
  module M = Preface_make.Monad.Via_bind (struct
    type nonrec 'a t = ('a, T.t) t

    let return = valid

    let bind f = function Valid x -> f x | Invalid err -> Invalid err
  end)

  module T (M : Preface_specs.MONAD) =
    Preface_make.Traversable.Over_monad
      (M)
      (struct
        type 'a t = 'a M.t

        type 'a iter = ('a, T.t) Bifunctor.t

        let traverse f x = traverse_aux M.return M.map f x
      end)

  include Preface_make.Traversable.Join_with_monad (M) (T)
end

module Foldable (T : Preface_specs.Types.T0) =
Preface_make.Foldable.Via_fold_right (struct
  type nonrec 'a t = ('a, T.t) t

  let fold_right f validation x =
    (match validation with Valid r -> f r x | Invalid _ -> x)
  ;;
end)

let equal f g left right =
  match (left, right) with
  | (Valid x, Valid y) -> f x y
  | (Invalid x, Invalid y) -> g x y
  | _ -> false
;;

let pp f g formater = function
  | Valid x -> Format.fprintf formater "Valid (%a)" f x
  | Invalid x -> Format.fprintf formater "Invalid (%a)" g x
;;
