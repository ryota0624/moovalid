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
  for x in self.tail {
    tail.push(x)
  }
  tail.push(other.head)
  for x in other.tail {
    tail.push(x)
  }
  { head: self.head, tail }
}
