let () =
  let open Alcotest in
  run "Preface_stdlib"
    ( Identity_test.cases
    @ Continuation_test.cases
    @ List_test.cases
    @ Nonempty_list_test.cases
    @ Option_test.cases
    @ State_test.cases
    @ Stream_test.cases
    @ Try_test.cases
    @ Pair_test.cases
    @ Predicate_test.cases
    @ Store_test.cases
    @ Env_test.cases
    @ Traced_test.cases )
;;
