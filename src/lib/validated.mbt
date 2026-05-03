/// `Validated[E, A]` is either a `Valid` success value or an `Invalid` error.
/// Unlike `Result`, combining two `Invalid` values accumulates both errors
/// (when `E` implements `Semigroup`) instead of short-circuiting.
pub(all) enum Validated[E, A] {
  Valid(A)
  Invalid(E)
} derive(Eq, Debug)

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
