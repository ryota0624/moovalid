// ─── Stage 4: Nel tests ───────────────────────────────────────────────────────

///|
test "Nel::to_array single element" {
  assert_eq(Nel::new(1).to_array(), [1])
}

///|
test "Nel::to_array multiple elements" {
  assert_eq(Nel::of(1, [2, 3]).to_array(), [1, 2, 3])
}

///|
test "Nel::length single element" {
  assert_eq(Nel::new(42).length(), 1)
}

///|
test "Nel::length multiple elements" {
  assert_eq(Nel::of(1, [2, 3]).length(), 3)
}

///|
test "Nel combine accumulates" {
  let a = Nel::of(1, [2])
  let b = Nel::of(3, [4])
  assert_eq(a.combine(b), Nel::of(1, [2, 3, 4]))
}
