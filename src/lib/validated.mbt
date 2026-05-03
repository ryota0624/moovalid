///|
/// `Validated[E, A]` is either a `Valid` success value or an `Invalid` error.
/// Unlike `Result`, combining two `Invalid` values accumulates both errors
/// (when `E` implements `Semigroup`) instead of short-circuiting.
pub(all) enum Validated[E, A] {
  Valid(A)
  Invalid(E)
} derive(Eq, Debug)

///|
/// Display a `Validated` value.  Used by `assert_eq` in tests.
pub impl[E : Show, A : Show] Show for Validated[E, A] with output(self, logger) {
  match self {
    Valid(a) => {
      logger.write_string("Valid(")
      a.output(logger)
      logger.write_string(")")
    }
    Invalid(e) => {
      logger.write_string("Invalid(")
      e.output(logger)
      logger.write_string(")")
    }
  }
}

///|
/// Apply a function to the success value, leaving errors unchanged.
///
/// ```
/// let v : Validated[String, Int] = Valid(3)
/// assert_eq(map(v, fn(x) { x * 2 }), Valid(6))
/// ```
pub fn[E, A, B] map(v : Validated[E, A], f : (A) -> B) -> Validated[E, B] {
  match v {
    Valid(a) => Valid(f(a))
    Invalid(e) => Invalid(e)
  }
}

///|
/// Apply a function to the error value, leaving success unchanged.
///
/// ```
/// let v : Validated[String, Int] = Invalid("oops")
/// assert_eq(map_error(v, fn(e) { e + "!" }), Invalid("oops!"))
/// ```
pub fn[E, F, A] map_error(v : Validated[E, A], f : (E) -> F) -> Validated[F, A] {
  match v {
    Valid(a) => Valid(a)
    Invalid(e) => Invalid(f(e))
  }
}

///|
/// Fold a `Validated` into a single value by providing handlers for each case.
///
/// ```
/// let v : Validated[String, Int] = Valid(42)
/// assert_eq(fold(v, fn(_) { 0 }, fn(x) { x }), 42)
/// ```
pub fn[E, A, B] fold(
  v : Validated[E, A],
  on_invalid : (E) -> B,
  on_valid : (A) -> B,
) -> B {
  match v {
    Valid(a) => on_valid(a)
    Invalid(e) => on_invalid(e)
  }
}

///|
/// Returns `true` if the value is `Valid`.
///
/// ```
/// assert_eq(is_valid(Valid(1)), true)
/// assert_eq(is_valid(Invalid("e")), false)
/// ```
pub fn[E, A] is_valid(v : Validated[E, A]) -> Bool {
  match v {
    Valid(_) => true
    Invalid(_) => false
  }
}

///|
/// Returns `true` if the value is `Invalid`.
///
/// ```
/// assert_eq(is_invalid(Invalid("e")), true)
/// assert_eq(is_invalid(Valid(1)), false)
/// ```
pub fn[E, A] is_invalid(v : Validated[E, A]) -> Bool {
  !is_valid(v)
}

///|
/// Return the success value, or a default if `Invalid`.
///
/// ```
/// let v : Validated[String, Int] = Invalid("e")
/// assert_eq(get_or_else(v, 0), 0)
/// ```
pub fn[E, A] get_or_else(v : Validated[E, A], default : A) -> A {
  match v {
    Valid(a) => a
    Invalid(_) => default
  }
}

///|
/// Return `self` if `Valid`, otherwise return `alternative`.
///
/// ```
/// let v : Validated[String, Int] = Invalid("e")
/// assert_eq(or_else(v, Valid(99)), Valid(99))
/// ```
pub fn[E, A] or_else(
  v : Validated[E, A],
  alternative : Validated[E, A],
) -> Validated[E, A] {
  match v {
    Valid(_) => v
    Invalid(_) => alternative
  }
}
