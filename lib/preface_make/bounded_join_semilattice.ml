module Core (Req : Preface_specs.Bounded_join_semilattice.WITH_JOIN) = Req

module Infix (Core : Preface_specs.Bounded_join_semilattice.CORE) = struct
  include Join_semilattice.Infix (Core)
end

module Via
    (Core : Preface_specs.Bounded_join_semilattice.CORE)
    (Infix : Preface_specs.Bounded_join_semilattice.INFIX) =
struct
  include Core
  module Infix = Infix
  include Infix
end

module Via_join (Req : Preface_specs.Bounded_join_semilattice.WITH_JOIN) =
struct
  module Core = Core (Req)
  include Core
  module Infix = Infix (Core)
  include Infix
end
