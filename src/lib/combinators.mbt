/// Combine two `Validated` values using an applicative-style binary function.
/// - Both `Valid` → apply `f` to the two inner values.
/// - One `Invalid` → propagate that error.
/// - Both `Invalid` → combine the two errors with `Semigroup::combine`.
pub fn[E : Semigroup, A, B, C] map2(
  va : Validated[E, A],
  vb : Validated[E, B],
  f : (A, B) -> C
) -> Validated[E, C] {
  match (va, vb) {
    (Valid(a), Valid(b)) => Valid(f(a, b))
    (Invalid(e), Valid(_)) => Invalid(e)
    (Valid(_), Invalid(e)) => Invalid(e)
    (Invalid(e1), Invalid(e2)) => Invalid(e1.combine(e2))
  }
}

/// Combine three `Validated` values with a ternary function.
/// All errors from `Invalid` branches are accumulated.
pub fn[E : Semigroup, A, B, C, D] map3(
  va : Validated[E, A],
  vb : Validated[E, B],
  vc : Validated[E, C],
  f : (A, B, C) -> D
) -> Validated[E, D] {
  map2(map2(va, vb, fn(a, b) { (a, b) }), vc, fn(ab, c) {
    f(ab.0, ab.1, c)
  })
}

/// Applicative `ap`: apply a validated function to a validated argument.
pub fn[E : Semigroup, A, B] ap(
  vf : Validated[E, (A) -> B],
  va : Validated[E, A]
) -> Validated[E, B] {
  map2(vf, va, fn(f, a) { f(a) })
}
