// ─── Stage 6: Validator tests ─────────────────────────────────────────────────

test "Validator::new and run success" {
  let v = Validator::new(fn(x : Int) {
    if x > 0 { Valid(x) } else { Invalid("negative") }
  })
  assert_eq(v.run(1), Valid(1))
}

test "Validator::new and run failure" {
  let v = Validator::new(fn(x : Int) {
    if x > 0 { Valid(x) } else { Invalid("negative") }
  })
  assert_eq(v.run(-1), Invalid("negative"))
}

test "Validator::map transforms success" {
  let v : Validator[Int, String, Int] = Validator::new(fn(x : Int) { Valid(x) }).map(fn(x) { x * 2 })
  assert_eq(v.run(3), Valid(6))
}

test "Validator::and_then chains validators" {
  let v = Validator::new(fn(x : Int) {
    if x > 0 { Valid(x) } else { Invalid(Nel::new("not positive")) }
  }).and_then(fn(x) {
    Validator::new(fn(_i) {
      if x < 100 { Valid(x) } else { Invalid(Nel::new("too large")) }
    })
  })
  assert_eq(v.run(5), Valid(5))
  assert_eq(v.run(-1), Invalid(Nel::new("not positive")))
  assert_eq(v.run(200), Invalid(Nel::new("too large")))
}

test "Validator::zip accumulates errors" {
  let v1 = Validator::new(fn(s : String) {
    if s.length() > 0 {
      Valid(s)
    } else {
      Invalid(Nel::new("empty"))
    }
  })
  let v2 = Validator::new(fn(s : String) {
    if s.length() <= 5 {
      Valid(s.length())
    } else {
      Invalid(Nel::new("too long"))
    }
  })
  let zipped = v1.zip(v2)
  assert_eq(zipped.run("hi"), Valid(("hi", 2)))
  assert_eq(zipped.run(""), Invalid(Nel::new("empty")))
}

test "non_empty passes non-empty string" {
  assert_eq(non_empty().run("hi"), Valid("hi"))
}

test "non_empty fails empty string" {
  assert_eq(non_empty().run(""), Invalid(Nel::new("must be non-empty")))
}

test "min_length passes" {
  assert_eq(min_length(3).run("abc"), Valid("abc"))
}

test "min_length fails" {
  assert_eq(min_length(3).run("ab"), Invalid(Nel::new("must have length >= 3")))
}

test "max_length passes" {
  assert_eq(max_length(3).run("abc"), Valid("abc"))
}

test "max_length fails" {
  assert_eq(max_length(3).run("abcd"), Invalid(Nel::new("must have length <= 3")))
}

test "in_range passes" {
  assert_eq(in_range(1, 10).run(5), Valid(5))
}

test "in_range fails above" {
  assert_eq(in_range(1, 10).run(11), Invalid(Nel::new("must be in range [1, 10]")))
}

test "in_range fails below" {
  assert_eq(in_range(1, 10).run(0), Invalid(Nel::new("must be in range [1, 10]")))
}
