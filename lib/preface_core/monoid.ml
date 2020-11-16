let times combine n x =
  if n > 0
  then
    let result = Array.make (pred n) x |> Array.fold_left combine x in
    Some result
  else None
;;

let reduce_nel combine list = Nonempty_list.reduce combine list

let reduce combine neutral list = List.fold_left combine neutral list
