module type LAWS = sig
  module Bounded_join_semilattice : Preface_specs.BOUNDED_JOIN_SEMILATTICE

  include
    Join_semilattice.LAWS
      with module Join_semilattice := Bounded_join_semilattice

  val bounded_join_semilattice_1 :
    unit -> (Bounded_join_semilattice.t, Bounded_join_semilattice.t) Law.t
end

module For (L : Preface_specs.BOUNDED_JOIN_SEMILATTICE) :
  LAWS with module Bounded_join_semilattice := L = struct
  open Law
  include Join_semilattice.For (L)

  let bounded_join_semilattice_1 () =
    let lhs x = L.join x L.bottom
    and rhs x = x in
    law ("join x bottom" =~ lhs) ("x" =~ rhs)
  ;;
end
