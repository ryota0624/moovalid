// ─── Step 1: Test-first – all cases from the specification ───────────────────

// 1. Success case: two Valid values composed with map2 return the correct result.
test "map2 combines two Valid values" {
  let v1 : Validated[Nel[String], Int] = Valid(3)
  let v2 : Validated[Nel[String], Int] = Valid(4)
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq!(result, Valid(7))
}

// 2. Single failure: one Invalid + one Valid returns the error unchanged.
test "map2 propagates a single Invalid" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("required"))
  let v2 : Validated[Nel[String], Int] = Valid(10)
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq!(result, Invalid(Nel::new("required")))
}

test "map2 propagates single Invalid on right side" {
  let v1 : Validated[Nel[String], Int] = Valid(10)
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("too small"))
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq!(result, Invalid(Nel::new("too small")))
}

// 3. Error accumulation: two Invalid values combined with map2 return all errors.
test "map2 accumulates errors from two Invalid values" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("error1"))
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("error2"))
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq!(result, Invalid(Nel::of("error1", ["error2"])))
}

// Error accumulation with map3: all three Invalid errors appear in the result.
test "map3 accumulates errors from three Invalid values" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("e1"))
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("e2"))
  let v3 : Validated[Nel[String], Int] = Invalid(Nel::new("e3"))
  let result = map3(v1, v2, v3, fn(a, b, c) { a + b + c })
  assert_eq!(result, Invalid(Nel::of("e1", ["e2", "e3"])))
}

test "map3 combines three Valid values" {
  let v1 : Validated[Nel[String], Int] = Valid(1)
  let v2 : Validated[Nel[String], Int] = Valid(2)
  let v3 : Validated[Nel[String], Int] = Valid(3)
  let result = map3(v1, v2, v3, fn(a, b, c) { a + b + c })
  assert_eq!(result, Valid(6))
}

// 4. Conversion: Result → Validated (from_result).
test "from_result converts Ok to Valid" {
  let r : Result[Int, String] = Ok(42)
  assert_eq!(from_result(r), Valid(42))
}

test "from_result converts Err to Invalid" {
  let r : Result[Int, String] = Err("something went wrong")
  assert_eq!(from_result(r), Invalid("something went wrong"))
}

// 4. Conversion: Validated → Result (to_result).
test "to_result converts Valid to Ok" {
  let v : Validated[String, Int] = Valid(100)
  assert_eq!(to_result(v), Ok(100))
}

test "to_result converts Invalid to Err" {
  let v : Validated[String, Int] = Invalid("not valid")
  assert_eq!(to_result(v), Err("not valid"))
}

// Round-trip: Result → Validated → Result is identity.
test "round-trip Ok through Validated" {
  let original : Result[Int, String] = Ok(7)
  assert_eq!(to_result(from_result(original)), original)
}

test "round-trip Err through Validated" {
  let original : Result[Int, String] = Err("bad input")
  assert_eq!(to_result(from_result(original)), original)
}

// ap: applicative application accumulates errors.
test "ap applies Valid function to Valid value" {
  let vf : Validated[Nel[String], (Int) -> Int] = Valid(fn(x) { x * 2 })
  let va : Validated[Nel[String], Int] = Valid(5)
  assert_eq!(ap(vf, va), Valid(10))
}

test "ap accumulates errors when both are Invalid" {
  let vf : Validated[Nel[String], (Int) -> Int] = Invalid(Nel::new("bad fn"))
  let va : Validated[Nel[String], Int] = Invalid(Nel::new("bad arg"))
  assert_eq!(ap(vf, va), Invalid(Nel::of("bad fn", ["bad arg"])))
}
