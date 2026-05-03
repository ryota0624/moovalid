///|
/// Combine two `Validated` values using an applicative-style binary function.
/// - Both `Valid` → apply `f` to the two inner values.
/// - One `Invalid` → propagate that error.
/// - Both `Invalid` → combine the two errors with `Semigroup::combine`.
pub fn[E : Semigroup, A, B, C] map2(
  va : Validated[E, A],
  vb : Validated[E, B],
  f : (A, B) -> C,
) -> Validated[E, C] {
  match (va, vb) {
    (Valid(a), Valid(b)) => Valid(f(a, b))
    (Invalid(e), Valid(_)) => Invalid(e)
    (Valid(_), Invalid(e)) => Invalid(e)
    (Invalid(e1), Invalid(e2)) => Invalid(e1.combine(e2))
  }
}

///|
/// Combine three `Validated` values with a ternary function.
/// All errors from `Invalid` branches are accumulated.
pub fn[E : Semigroup, A, B, C, D] map3(
  va : Validated[E, A],
  vb : Validated[E, B],
  vc : Validated[E, C],
  f : (A, B, C) -> D,
) -> Validated[E, D] {
  map2(map2(va, vb, fn(a, b) { (a, b) }), vc, fn(ab, c) { f(ab.0, ab.1, c) })
}

///|
/// Applicative `ap`: apply a validated function to a validated argument.
pub fn[E : Semigroup, A, B] ap(
  vf : Validated[E, (A) -> B],
  va : Validated[E, A],
) -> Validated[E, B] {
  map2(vf, va, fn(f, a) { f(a) })
}

///|
/// Collect an array of `Validated` values into a single `Validated` of an array.
/// All errors are accumulated; if all are `Valid` the results are collected.
///
/// ```
/// let vs = [Valid(1), Valid(2), Valid(3)]
/// assert_eq(sequence(vs), Valid([1, 2, 3]))
/// ```
pub fn[E : Semigroup, A] sequence(
  xs : Array[Validated[E, A]],
) -> Validated[E, Array[A]] {
  let mut acc : Validated[E, Array[A]] = Valid([])
  for v in xs {
    acc = map2(acc, v, fn(arr, a) {
      arr.push(a)
      arr
    })
  }
  acc
}

///|
/// Map each element of an array through a validating function, then collect.
/// All errors are accumulated.
///
/// ```
/// let result = traverse([1, 2, 3], fn(x) { Valid(x * 2) })
/// assert_eq(result, Valid([2, 4, 6]))
/// ```
pub fn[E : Semigroup, A, B] traverse(
  xs : Array[A],
  f : (A) -> Validated[E, B],
) -> Validated[E, Array[B]] {
  sequence(xs.map(f))
}
