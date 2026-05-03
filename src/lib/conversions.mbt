///|
/// Convert a `Validated` into a standard `Result`.
/// `Valid(a)` becomes `Ok(a)`, `Invalid(e)` becomes `Err(e)`.
pub fn[E, A] to_result(v : Validated[E, A]) -> Result[A, E] {
  match v {
    Valid(a) => Ok(a)
    Invalid(e) => Err(e)
  }
}

///|
/// Convert a standard `Result` into a `Validated`.
/// `Ok(a)` becomes `Valid(a)`, `Err(e)` becomes `Invalid(e)`.
pub fn[E, A] from_result(r : Result[A, E]) -> Validated[E, A] {
  match r {
    Ok(a) => Valid(a)
    Err(e) => Invalid(e)
  }
}

///|
/// Attempt execution and capture raises into Validated.
/// Runs `f` and wraps a successful result in `Valid(a)`.
/// If `f` raises an error `e`, captures it as `Invalid(Nel::new(e))`.
/// The resulting `Validated[Nel[E], A]` can be composed with `map2`/`map3`
/// to accumulate errors across multiple `attempt` calls.
pub fn[E : Error, A] attempt(f : () -> A raise E) -> Validated[Nel[E], A] {
  attempt_into(f, fn(e) { Nel::new(e) })
}

///|
/// Convert a `Validated` to an `Option`, discarding errors.
/// `Valid(a)` becomes `Some(a)`, `Invalid(_)` becomes `None`.
///
/// ```
/// let v : Validated[String, Int] = Valid(5)
/// assert_eq(to_option(v), Some(5))
/// ```
pub fn[E, A] to_option(v : Validated[E, A]) -> A? {
  match v {
    Valid(a) => Some(a)
    Invalid(_) => None
  }
}

///|
/// Lift an `Option` into `Validated`, using `on_none` as the error if `None`.
///
/// ```
/// assert_eq(from_option(Some(1), "missing"), Valid(1))
/// assert_eq(from_option(None, "missing"), Invalid("missing"))
/// ```
pub fn[E, A] from_option(opt : A?, on_none : E) -> Validated[E, A] {
  match opt {
    Some(a) => Valid(a)
    None => Invalid(on_none)
  }
}

///|
/// Like `attempt`, but wraps the error with `wrap` before storing in `Invalid`.
/// Useful when mapping a specific error type into a custom accumulator type.
///
/// ```
/// // attempt_into(() => 42, fn(e) { Nel::new(e) }) == Valid(42)
/// ```
pub fn[E : Error, F, A] attempt_into(
  f : () -> A raise E,
  wrap : (E) -> F,
) -> Validated[F, A] {
  Valid(f()) catch {
    e => Invalid(wrap(e))
  }
}
