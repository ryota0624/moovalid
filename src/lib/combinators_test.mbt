// ─── Stage 3: sequence and traverse ─────────────────────────────────────────

///|
test "sequence all Valid returns Valid array" {
  let vs : Array[Validated[Nel[String], Int]] = [Valid(1), Valid(2), Valid(3)]
  assert_eq(sequence(vs), Valid([1, 2, 3]))
}

///|
test "sequence one Invalid returns that error" {
  let vs : Array[Validated[Nel[String], Int]] = [
    Valid(1),
    Invalid(Nel::new("e1")),
    Valid(3),
  ]
  assert_eq(sequence(vs), Invalid(Nel::new("e1")))
}

///|
test "sequence multiple Invalid accumulates errors" {
  let vs : Array[Validated[Nel[String], Int]] = [
    Invalid(Nel::new("e1")),
    Valid(2),
    Invalid(Nel::new("e2")),
  ]
  assert_eq(sequence(vs), Invalid(Nel::of("e1", ["e2"])))
}

///|
test "sequence empty array returns Valid empty array" {
  let vs : Array[Validated[Nel[String], Int]] = []
  assert_eq(sequence(vs), Valid([]))
}

///|
test "traverse all success" {
  let result = traverse([1, 2, 3], fn(x) { Valid(x * 2) })
  let expected : Validated[Nel[String], Array[Int]] = Valid([2, 4, 6])
  assert_eq(result, expected)
}

///|
test "traverse one failure" {
  let result : Validated[Nel[String], Array[Int]] = traverse([1, 2, 3], fn(x) {
    if x == 2 {
      Invalid(Nel::new("bad 2"))
    } else {
      Valid(x)
    }
  })
  assert_eq(result, Invalid(Nel::new("bad 2")))
}

///|
test "traverse multiple failures accumulates" {
  let result : Validated[Nel[String], Array[Int]] = traverse([1, 2, 3], fn(x) {
    if x != 2 {
      Invalid(Nel::new("bad \{x}"))
    } else {
      Valid(x)
    }
  })
  assert_eq(result, Invalid(Nel::of("bad 1", ["bad 3"])))
}

///|
test "traverse empty array" {
  let result = traverse([], fn(x : Int) { Valid(x) })
  let expected : Validated[Nel[String], Array[Int]] = Valid([])
  assert_eq(result, expected)
}
