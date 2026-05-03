/// Convert a `Validated` into a standard `Result`.
/// `Valid(a)` becomes `Ok(a)`, `Invalid(e)` becomes `Err(e)`.
pub fn[E, A] to_result(v : Validated[E, A]) -> Result[A, E] {
  match v {
    Valid(a) => Ok(a)
    Invalid(e) => Err(e)
  }
}

/// Convert a standard `Result` into a `Validated`.
/// `Ok(a)` becomes `Valid(a)`, `Err(e)` becomes `Invalid(e)`.
pub fn[E, A] from_result(r : Result[A, E]) -> Validated[E, A] {
  match r {
    Ok(a) => Valid(a)
    Err(e) => Invalid(e)
  }
}

/// Attempt execution and capture raises into Validated.
/// Runs `f` and wraps a successful result in `Valid(a)`.
/// If `f` raises an error `e`, captures it as `Invalid(Nel::new(e))`.
/// The resulting `Validated[Nel[E], A]` can be composed with `map2`/`map3`
/// to accumulate errors across multiple `attempt` calls.
pub fn[E : Error, A] attempt(f : () -> A raise E) -> Validated[Nel[E], A] {
  try {
    Valid(f())
  } catch {
    e => Invalid(Nel::new(e))
  }
}
