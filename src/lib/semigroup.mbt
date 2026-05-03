/// A `Semigroup` can combine two values of the same type into one.
/// Used to accumulate errors across multiple `Invalid` branches.
pub trait Semigroup {
  combine(Self, Self) -> Self
}
