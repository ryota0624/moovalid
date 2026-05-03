// quickstart.mbt — runnable example mirroring the README quick-start section.
//
// This file demonstrates how to use moovalid for form-style validation that
// accumulates all errors instead of failing on the first one.

///|
/// Validate that a username is non-empty and at most 20 characters.
fn validate_username(s : String) -> @lib.Validated[@lib.Nel[String], String] {
  if s.length() == 0 {
    @lib.Invalid(@lib.Nel::new("username must not be empty"))
  } else if s.length() > 20 {
    @lib.Invalid(@lib.Nel::new("username must be <= 20 chars"))
  } else {
    @lib.Valid(s)
  }
}

///|
/// Validate that a user's age is 18 or older.
fn validate_age(n : Int) -> @lib.Validated[@lib.Nel[String], Int] {
  if n < 18 {
    @lib.Invalid(@lib.Nel::new("must be 18 or older"))
  } else {
    @lib.Valid(n)
  }
}

///|
struct User {
  username : String
  age : Int
} derive(Debug)

///|
pub impl Show for User with output(self, logger) {
  logger.write_string("User { username: ")
  logger.write_string(self.username)
  logger.write_string(", age: ")
  logger.write_string(self.age.to_string())
  logger.write_string(" }")
}

///|
/// Combine both validators; errors accumulate when both fields are invalid.
fn register(
  username : String,
  age : Int,
) -> @lib.Validated[@lib.Nel[String], User] {
  @lib.map2(validate_username(username), validate_age(age), fn(u, a) {
    { username: u, age: a }
  })
}

///|
/// Entry point: run several scenarios and print the results.
fn main {
  // 1. Happy path
  println(register("alice", 25).to_string())
  // => Valid({ username: alice, age: 25 })

  // 2. Single error
  println(register("", 25).to_string())
  // => Invalid(Nel { head: "username must not be empty", tail: [] })

  // 3. Both errors accumulated
  println(register("", 15).to_string())
  // => Invalid(Nel { head: "username must not be empty",
  //                  tail: ["must be 18 or older"] })

  // 4. Validator API — built-in rules
  let v = @lib.non_empty().zip(@lib.max_length(10))
  println(v.run("hi").to_string())
  // => Valid(("hi", "hi"))
  println(v.run("").to_string())
  // => Invalid(Nel { head: "must be non-empty", tail: [] })
}
