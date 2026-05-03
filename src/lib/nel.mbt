/// `Nel[T]` – a non-empty list that holds at least one value.
/// Used as the canonical error accumulator together with `Semigroup`.
pub struct Nel[T] {
  head : T
  tail : Array[T]
} derive(Eq, Debug)

/// Create a `Nel` with a single element.
pub fn[T] Nel::new(head : T) -> Nel[T] {
  { head, tail: [] }
}

/// Create a `Nel` from a head element and an existing tail array.
pub fn[T] Nel::of(head : T, tail : Array[T]) -> Nel[T] {
  { head, tail }
}

/// Display a `Nel` value.  Used by `assert_eq` in tests.
pub impl[T : Show] Show for Nel[T] with output(self, logger) {
  logger.write_string("{ head: ")
  self.head.output(logger)
  logger.write_string(", tail: [")
  let mut first = true
  for x in self.tail {
    if !first {
      logger.write_string(", ")
    }
    first = false
    x.output(logger)
  }
  logger.write_string("] }")
}

/// Combine two `Nel` values by appending the second after the first.
pub impl[T] Semigroup for Nel[T] with combine(self, other) {
  let tail : Array[T] = []
  tail.push_iter(self.tail.iter())
  tail.push(other.head)
  tail.push_iter(other.tail.iter())
  { head: self.head, tail }
}

/// Convert a `Nel` to a plain `Array`.
///
/// ```
/// let nel = Nel::of(1, [2, 3])
/// assert_eq(nel.to_array(), [1, 2, 3])
/// ```
pub fn[T] Nel::to_array(self : Nel[T]) -> Array[T] {
  let arr : Array[T] = [self.head]
  for x in self.tail {
    arr.push(x)
  }
  arr
}

/// Return the number of elements in a `Nel`.
///
/// ```
/// assert_eq(Nel::new(1).length(), 1)
/// assert_eq(Nel::of(1, [2, 3]).length(), 3)
/// ```
pub fn[T] Nel::length(self : Nel[T]) -> Int {
  1 + self.tail.length()
}
