/// A `Semigroup` can combine two values of the same type into one.
/// Used to accumulate errors across multiple `Invalid` branches.
pub trait Semigroup {
  combine(Self, Self) -> Self
}

/// `Nel[T]` – a non-empty list that holds at least one value.
/// Used as the canonical error accumulator together with `Semigroup`.
pub struct Nel[T] {
  head : T
  tail : Array[T]
} derive(Eq, Show)

/// Create a `Nel` with a single element.
pub fn Nel::new[T](head : T) -> Nel[T] {
  { head, tail: [] }
}

/// Create a `Nel` from a head element and an existing tail array.
pub fn Nel::of[T](head : T, tail : Array[T]) -> Nel[T] {
  { head, tail }
}

/// Combine two `Nel` values by appending the second after the first.
impl[T] Semigroup for Nel[T] with combine(self, other) {
  let tail : Array[T] = []
  for x in self.tail {
    tail.push(x)
  }
  tail.push(other.head)
  for x in other.tail {
    tail.push(x)
  }
  { head: self.head, tail }
}

/// `Validated[E, A]` is either a `Valid` success value or an `Invalid` error.
/// Unlike `Result`, combining two `Invalid` values accumulates both errors
/// (when `E` implements `Semigroup`) instead of short-circuiting.
pub enum Validated[E, A] {
  Valid(A)
  Invalid(E)
} derive(Eq, Show)

/// Combine two `Validated` values using an applicative-style binary function.
/// - Both `Valid` → apply `f` to the two inner values.
/// - One `Invalid` → propagate that error.
/// - Both `Invalid` → combine the two errors with `Semigroup::combine`.
pub fn map2[E : Semigroup, A, B, C](
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
pub fn map3[E : Semigroup, A, B, C, D](
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
pub fn ap[E : Semigroup, A, B](
  vf : Validated[E, (A) -> B],
  va : Validated[E, A]
) -> Validated[E, B] {
  map2(vf, va, fn(f, a) { f(a) })
}

/// Convert a `Validated` into a standard `Result`.
/// `Valid(a)` becomes `Ok(a)`, `Invalid(e)` becomes `Err(e)`.
pub fn to_result[E, A](v : Validated[E, A]) -> Result[A, E] {
  match v {
    Valid(a) => Ok(a)
    Invalid(e) => Err(e)
  }
}

/// Convert a standard `Result` into a `Validated`.
/// `Ok(a)` becomes `Valid(a)`, `Err(e)` becomes `Invalid(e)`.
pub fn from_result[E, A](r : Result[A, E]) -> Validated[E, A] {
  match r {
    Ok(a) => Valid(a)
    Err(e) => Invalid(e)
  }
}
