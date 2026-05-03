// ─── Step 1: Test-first – all cases from the specification ───────────────────

// 1. Success case: two Valid values composed with map2 return the correct result.
test "map2 combines two Valid values" {
  let v1 : Validated[Nel[String], Int] = Valid(3)
  let v2 : Validated[Nel[String], Int] = Valid(4)
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Valid(7))
}

// 2. Single failure: one Invalid + one Valid returns the error unchanged.
test "map2 propagates a single Invalid" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("required"))
  let v2 : Validated[Nel[String], Int] = Valid(10)
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Invalid(Nel::new("required")))
}

test "map2 propagates single Invalid on right side" {
  let v1 : Validated[Nel[String], Int] = Valid(10)
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("too small"))
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Invalid(Nel::new("too small")))
}

// 3. Error accumulation: two Invalid values combined with map2 return all errors.
test "map2 accumulates errors from two Invalid values" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("error1"))
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("error2"))
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(result, Invalid(Nel::of("error1", ["error2"])))
}

// Error accumulation with map3: all three Invalid errors appear in the result.
test "map3 accumulates errors from three Invalid values" {
  let v1 : Validated[Nel[String], Int] = Invalid(Nel::new("e1"))
  let v2 : Validated[Nel[String], Int] = Invalid(Nel::new("e2"))
  let v3 : Validated[Nel[String], Int] = Invalid(Nel::new("e3"))
  let result = map3(v1, v2, v3, fn(a, b, c) { a + b + c })
  assert_eq(result, Invalid(Nel::of("e1", ["e2", "e3"])))
}

test "map3 combines three Valid values" {
  let v1 : Validated[Nel[String], Int] = Valid(1)
  let v2 : Validated[Nel[String], Int] = Valid(2)
  let v3 : Validated[Nel[String], Int] = Valid(3)
  let result = map3(v1, v2, v3, fn(a, b, c) { a + b + c })
  assert_eq(result, Valid(6))
}

// 4. Conversion: Result → Validated (from_result).
test "from_result converts Ok to Valid" {
  let r : Result[Int, String] = Ok(42)
  assert_eq(from_result(r), Valid(42))
}

test "from_result converts Err to Invalid" {
  let r : Result[Int, String] = Err("something went wrong")
  assert_eq(from_result(r), Invalid("something went wrong"))
}

// 4. Conversion: Validated → Result (to_result).
test "to_result converts Valid to Ok" {
  let v : Validated[String, Int] = Valid(100)
  assert_eq(to_result(v), Ok(100))
}

test "to_result converts Invalid to Err" {
  let v : Validated[String, Int] = Invalid("not valid")
  assert_eq(to_result(v), Err("not valid"))
}

// Round-trip: Result → Validated → Result is identity.
test "round-trip Ok through Validated" {
  let original : Result[Int, String] = Ok(7)
  assert_eq(to_result(from_result(original)), original)
}

test "round-trip Err through Validated" {
  let original : Result[Int, String] = Err("bad input")
  assert_eq(to_result(from_result(original)), original)
}

// ap: applicative application accumulates errors.
test "ap applies Valid function to Valid value" {
  let vf : Validated[Nel[String], (Int) -> Int] = Valid(fn(x) { x * 2 })
  let va : Validated[Nel[String], Int] = Valid(5)
  assert_eq(ap(vf, va), Valid(10))
}

test "ap accumulates errors when both are Invalid" {
  let vf : Validated[Nel[String], (Int) -> Int] = Invalid(Nel::new("bad fn"))
  let va : Validated[Nel[String], Int] = Invalid(Nel::new("bad arg"))
  assert_eq(ap(vf, va), Invalid(Nel::of("bad fn", ["bad arg"])))
}

// ─── attempt tests ────────────────────────────────────────────────────────────

suberror AttemptError { AttemptError(String) } derive(Eq, Debug)

pub impl Show for AttemptError with output(self, logger) {
  let AttemptError(s) = self
  logger.write_string("AttemptError(")
  s.output(logger)
  logger.write_string(")")
}

// 1. attempt success: a non-raising closure is wrapped in Valid.
test "attempt wraps success in Valid" {
  let result : Validated[Nel[AttemptError], Int] = attempt(() => 42)
  assert_eq(result, Valid(42))
}

// 2. attempt capture: a raised error is caught and stored in Invalid.
test "attempt captures raised error as Invalid" {
  let result : Validated[Nel[AttemptError], Int] = attempt(
    () => raise AttemptError("failed"),
  )
  assert_eq(result, Invalid(Nel::new(AttemptError("failed"))))
}

// 3. error accumulation: two Invalid attempt results compose with map2.
test "attempt errors accumulate with map2" {
  let v1 : Validated[Nel[AttemptError], Int] = attempt(
    () => raise AttemptError("err1"),
  )
  let v2 : Validated[Nel[AttemptError], Int] = attempt(
    () => raise AttemptError("err2"),
  )
  let result = map2(v1, v2, fn(a, b) { a + b })
  assert_eq(
    result,
    Invalid(Nel::of(AttemptError("err1"), [AttemptError("err2")])),
  )
}

// 4. round-trip: convert an attempt result back to Result via to_result.
test "to_result from attempt Valid returns Ok" {
  let v : Validated[Nel[AttemptError], Int] = attempt(() => 99)
  assert_eq(to_result(v), Ok(99))
}

test "to_result from attempt Invalid returns Err" {
  let v : Validated[Nel[AttemptError], Int] = attempt(
    () => raise AttemptError("oops"),
  )
  assert_eq(to_result(v), Err(Nel::new(AttemptError("oops"))))
}

// ─── Stage 2: map, map_error, fold, predicates, get_or_else, or_else ─────────

test "map transforms Valid value" {
  let v : Validated[String, Int] = Valid(3)
  assert_eq(map(v, fn(x) { x * 2 }), Valid(6))
}

test "map preserves Invalid" {
  let v : Validated[String, Int] = Invalid("err")
  assert_eq(map(v, fn(x) { x * 2 }), Invalid("err"))
}

test "map_error transforms Invalid value" {
  let v : Validated[String, Int] = Invalid("oops")
  assert_eq(map_error(v, fn(e) { e + "!" }), Invalid("oops!"))
}

test "map_error preserves Valid" {
  let v : Validated[String, Int] = Valid(5)
  assert_eq(map_error(v, fn(e) { e + "!" }), Valid(5))
}

test "fold on Valid calls on_valid" {
  let v : Validated[String, Int] = Valid(42)
  assert_eq(fold(v, fn(_) { 0 }, fn(x) { x }), 42)
}

test "fold on Invalid calls on_invalid" {
  let v : Validated[String, Int] = Invalid("bad")
  assert_eq(fold(v, fn(_) { -1 }, fn(x) { x }), -1)
}

test "is_valid returns true for Valid" {
  let v : Validated[String, Int] = Valid(1)
  assert_eq(is_valid(v), true)
}

test "is_valid returns false for Invalid" {
  let v : Validated[String, Int] = Invalid("e")
  assert_eq(is_valid(v), false)
}

test "is_invalid returns true for Invalid" {
  let v : Validated[String, Int] = Invalid("e")
  assert_eq(is_invalid(v), true)
}

test "is_invalid returns false for Valid" {
  let v : Validated[String, Int] = Valid(1)
  assert_eq(is_invalid(v), false)
}

test "get_or_else returns value for Valid" {
  let v : Validated[String, Int] = Valid(7)
  assert_eq(get_or_else(v, 0), 7)
}

test "get_or_else returns default for Invalid" {
  let v : Validated[String, Int] = Invalid("e")
  assert_eq(get_or_else(v, 0), 0)
}

test "or_else returns self when Valid" {
  let v : Validated[String, Int] = Valid(1)
  assert_eq(or_else(v, Valid(99)), Valid(1))
}

test "or_else returns alternative when Invalid" {
  let v : Validated[String, Int] = Invalid("e")
  assert_eq(or_else(v, Valid(99)), Valid(99))
}

test "or_else chains two Invalids" {
  let v : Validated[String, Int] = Invalid("first")
  assert_eq(or_else(v, Invalid("second")), Invalid("second"))
}
