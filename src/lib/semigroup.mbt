/// A `Semigroup` can combine two values of the same type into one.
/// Used to accumulate errors across multiple `Invalid` branches.
pub trait Semigroup {
  combine(Self, Self) -> Self
}

/// Semigroup for String via concatenation.
pub impl Semigroup for String with combine(self, other) {
  self + other
}

/// Semigroup for Array[T] via appending.
pub impl[T] Semigroup for Array[T] with combine(self, other) {
  let arr : Array[T] = []
  for x in self {
    arr.push(x)
  }
  for x in other {
    arr.push(x)
  }
  arr
}
