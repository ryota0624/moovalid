///|
/// A `Validator[I, E, A]` is a function from input `I` to `Validated[E, A]`.
/// Validators can be composed via `map`, `and_then`, and `zip`.
pub struct Validator[I, E, A] {
  validate : (I) -> Validated[E, A]
}

///|
/// Construct a `Validator` from a raw function.
///
/// ```
/// let v = Validator::new(fn(x : Int) { if x > 0 { Valid(x) } else { Invalid("negative") } })
/// assert_eq(v.run(1), Valid(1))
/// ```
pub fn[I, E, A] Validator::new(
  f : (I) -> Validated[E, A],
) -> Validator[I, E, A] {
  { validate: f }
}

///|
/// Run the validator against an input and return a `Validated` result.
pub fn[I, E, A] Validator::run(
  self : Validator[I, E, A],
  input : I,
) -> Validated[E, A] {
  (self.validate)(input)
}

///|
/// Transform the success output of a validator.
pub fn[I, E, A, B] Validator::map(
  self : Validator[I, E, A],
  f : (A) -> B,
) -> Validator[I, E, B] {
  Validator::new(fn(i) { map((self.validate)(i), f) })
}

///|
/// Chain validators, threading the output of the first into a function that
/// produces the next validator.
pub fn[I, E, A, B] Validator::and_then(
  self : Validator[I, E, A],
  next : (A) -> Validator[I, E, B],
) -> Validator[I, E, B] {
  Validator::new(fn(i) {
    match (self.validate)(i) {
      Valid(a) => (next(a).validate)(i)
      Invalid(e) => Invalid(e)
    }
  })
}

///|
/// Run two validators on the same input and accumulate errors via `Semigroup`.
pub fn[I, E : Semigroup, A, B] Validator::zip(
  self : Validator[I, E, A],
  other : Validator[I, E, B],
) -> Validator[I, E, (A, B)] {
  Validator::new(fn(i) {
    map2((self.validate)(i), (other.validate)(i), fn(a, b) { (a, b) })
  })
}

// ─── Built-in rules ───────────────────────────────────────────────────────────

///|
/// Validate that a string is non-empty.
///
/// ```
/// assert_eq(non_empty().run("hi"), Valid("hi"))
/// assert_eq(non_empty().run(""), Invalid(Nel::new("must be non-empty")))
/// ```
pub fn non_empty() -> Validator[String, Nel[String], String] {
  Validator::new(fn(s) {
    if s.length() > 0 {
      Valid(s)
    } else {
      Invalid(Nel::new("must be non-empty"))
    }
  })
}

///|
/// Validate that a string has at least `n` characters.
///
/// ```
/// assert_eq(min_length(3).run("ab"), Invalid(Nel::new("must have length >= 3")))
/// assert_eq(min_length(3).run("abc"), Valid("abc"))
/// ```
pub fn min_length(n : Int) -> Validator[String, Nel[String], String] {
  Validator::new(fn(s) {
    if s.length() >= n {
      Valid(s)
    } else {
      Invalid(Nel::new("must have length >= \{n}"))
    }
  })
}

///|
/// Validate that a string has at most `n` characters.
///
/// ```
/// assert_eq(max_length(3).run("abcd"), Invalid(Nel::new("must have length <= 3")))
/// assert_eq(max_length(3).run("abc"), Valid("abc"))
/// ```
pub fn max_length(n : Int) -> Validator[String, Nel[String], String] {
  Validator::new(fn(s) {
    if s.length() <= n {
      Valid(s)
    } else {
      Invalid(Nel::new("must have length <= \{n}"))
    }
  })
}

///|
/// Validate that an integer falls within the inclusive range `[lo, hi]`.
///
/// ```
/// assert_eq(in_range(1, 10).run(5), Valid(5))
/// assert_eq(in_range(1, 10).run(11), Invalid(Nel::new("must be in range [1, 10]")))
/// ```
pub fn in_range(lo : Int, hi : Int) -> Validator[Int, Nel[String], Int] {
  Validator::new(fn(x) {
    if x >= lo && x <= hi {
      Valid(x)
    } else {
      Invalid(Nel::new("must be in range [\{lo}, \{hi}]"))
    }
  })
}

// ─── FieldError ───────────────────────────────────────────────────────────────

///|
/// An error paired with a path describing which field it came from.
pub struct FieldError[M] {
  path : Array[String]
  message : M
} derive(Eq, Debug)

///|
/// Create a `FieldError` with the given path and message.
pub fn[M] FieldError::new(
  path : Array[String],
  message : M,
) -> FieldError[M] {
  { path, message }
}

///|
/// Display a `FieldError` as `"<path>: <message>"`.
pub impl[M : Show] Show for FieldError[M] with output(self, logger) {
  let joined = self.path.join(".")
  if joined.length() > 0 {
    logger.write_string(joined)
    logger.write_string(": ")
  }
  logger.write_string(self.message.to_string())
}

///|
/// Prefix all `FieldError` paths in a `Nel[FieldError[M]]` with `name`.
pub fn[I, M, A] Validator::at_field(
  self : Validator[I, Nel[FieldError[M]], A],
  name : String,
) -> Validator[I, Nel[FieldError[M]], A] {
  Validator::new(fn(i) {
    match (self.validate)(i) {
      Valid(a) => Valid(a)
      Invalid(errs) => {
        fn prefix(fe : FieldError[M]) -> FieldError[M] {
          let new_path : Array[String] = [name]
          for p in fe.path {
            new_path.push(p)
          }
          { path: new_path, message: fe.message }
        }
        Invalid({ head: prefix(errs.head), tail: errs.tail.map(prefix) })
      }
    }
  })
}
