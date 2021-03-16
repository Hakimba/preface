module Core_via_map_and_product
    (Core : Preface_specs.Alternative.CORE_WITH_MAP_AND_PRODUCT) :
  Preface_specs.Alternative.CORE with type 'a t = 'a Core.t = struct
  include Applicative.Core_via_map_and_product (Core)

  let combine = Core.combine

  let neutral = Core.neutral
end

module Core_via_apply (Core : Preface_specs.Alternative.CORE_WITH_APPLY) :
  Preface_specs.Alternative.CORE with type 'a t = 'a Core.t = struct
  include Applicative.Core_via_apply (Core)

  let combine = Core.combine

  let neutral = Core.neutral
end

let reduce' combine neutral list = List.fold_left combine neutral list

module Operation (Core : Preface_specs.Alternative.CORE) :
  Preface_specs.Alternative.OPERATION with type 'a t = 'a Core.t = struct
  include Applicative.Operation (Core)
  include Alt.Operation (Core)

  let reduce list = reduce' Core.combine Core.neutral list
end

module Syntax (Core : Preface_specs.Alternative.CORE) :
  Preface_specs.Alternative.SYNTAX with type 'a t = 'a Core.t =
  Applicative.Syntax (Core)

module Infix
    (Core : Preface_specs.Alternative.CORE)
    (Operation : Preface_specs.Alternative.OPERATION with type 'a t = 'a Core.t) :
  Preface_specs.Alternative.INFIX with type 'a t = 'a Core.t = struct
  include Applicative.Infix (Core) (Operation)
  include Alt.Infix (Core) (Operation)
end

module Via
    (Core : Preface_specs.Alternative.CORE)
    (Operation : Preface_specs.Alternative.OPERATION with type 'a t = 'a Core.t)
    (Infix : Preface_specs.Alternative.INFIX with type 'a t = 'a Core.t)
    (Syntax : Preface_specs.Alternative.SYNTAX with type 'a t = 'a Core.t) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a Core.t = struct
  include Core
  include Operation
  include Syntax
  include Infix
  module Infix = Infix
  module Syntax = Syntax
end

module Via_map_and_product
    (Core_with_map_and_product : Preface_specs.Alternative
                                 .CORE_WITH_MAP_AND_PRODUCT) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a Core_with_map_and_product.t =
struct
  module Core = Core_via_map_and_product (Core_with_map_and_product)
  module Operation = Operation (Core)
  module Syntax = Syntax (Core)
  module Infix = Infix (Core) (Operation)
  include Core
  include Operation
  include Syntax
  include Infix
end

module Via_apply (Core_with_apply : Preface_specs.Alternative.CORE_WITH_APPLY) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a Core_with_apply.t = struct
  module Core = Core_via_apply (Core_with_apply)
  module Operation = Operation (Core)
  module Syntax = Syntax (Core)
  module Infix = Infix (Core) (Operation)
  include Core
  include Operation
  include Syntax
  include Infix
end

module Over_applicative
    (Applicative : Preface_specs.APPLICATIVE)
    (Core : Preface_specs.Alternative.CORE_WITH_NEUTRAL_AND_COMBINE
              with type 'a t = 'a Applicative.t) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a Core.t =
  Via
    (struct
      include Applicative

      let combine = Core.combine

      let neutral = Core.neutral
    end)
    (struct
      include Alt.Operation (struct
        include Applicative
        include Core
      end)

      include Applicative

      let reduce list = reduce' Core.combine Core.neutral list
    end)
    (struct
      type 'a t = 'a Applicative.t

      include Applicative.Infix

      let ( <|> ) = Core.combine
    end)
    (struct
      type 'a t = 'a Applicative.t

      include Applicative.Syntax
    end)

module Composition
    (F : Preface_specs.ALTERNATIVE)
    (G : Preface_specs.APPLICATIVE) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a G.t F.t =
  Over_applicative
    (Applicative.Composition (F) (G))
       (struct
         type 'a t = 'a G.t F.t

         let neutral = F.neutral

         let combine = F.combine
       end)

module From_arrow_plus (A : Preface_specs.ARROW_PLUS) :
  Preface_specs.ALTERNATIVE with type 'a t = (unit, 'a) A.t =
  Over_applicative
    (Applicative.From_arrow
       (A))
       (struct
         type 'a t = (unit, 'a) A.t

         let neutral = A.neutral

         let combine x y = A.(x <|> y)
       end)

module Product (F : Preface_specs.ALTERNATIVE) (G : Preface_specs.ALTERNATIVE) :
  Preface_specs.ALTERNATIVE with type 'a t = 'a F.t * 'a G.t =
  Over_applicative
    (Applicative.Product (F) (G))
       (struct
         type 'a t = 'a F.t * 'a G.t

         let neutral = (F.neutral, G.neutral)

         let combine (x1, y1) (x2, y2) = (F.combine x1 x2, G.combine y1 y2)
       end)
