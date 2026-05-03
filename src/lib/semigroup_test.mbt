// ─── Stage 4: Semigroup tests ─────────────────────────────────────────────────

// Test String Semigroup via sequence/map2 which internally uses combine
test "Semigroup String via map2" {
  let v1 : Validated[String, Int] = Invalid("hello")
  let v2 : Validated[String, Int] = Invalid(" world")
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Invalid("hello world"))
}

// Test Array[Int] Semigroup via sequence which internally uses combine
test "Semigroup Array via sequence" {
  let v1 : Validated[Array[Int], String] = Invalid([1, 2])
  let v2 : Validated[Array[Int], String] = Invalid([3, 4])
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Invalid([1, 2, 3, 4]))
}
