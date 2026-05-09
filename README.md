# moovalid

> A lightweight MoonBit validation library that **accumulates errors** instead of failing fast.

## Why moovalid?

MoonBit's built-in `Result` short-circuits on the first error — useful for control flow, but painful for form validation where you want to show *all* problems at once.

`moovalid` introduces `Validated[E, A]`: the same two variants as `Result`, but when you combine two `Invalid` values with `map2` / `map3`, **both** error payloads are merged (via `Semigroup`). Users see every field error in one round-trip.

## Installation

```
moon add ryota0624/moovalid
```

Then import in your `moon.pkg.json`:

```json
{ "import": ["ryota0624/moovalid/src/lib"] }
```

## Quick Start

```moonbit
// User registration: collect all errors at once
fn validate_username(s : String) -> Validated[Nel[String], String] {
  if s.length() == 0 {
    Invalid(Nel::new("username must not be empty"))
  } else if s.length() > 20 {
    Invalid(Nel::new("username must be <= 20 chars"))
  } else {
    Valid(s)
  }
}

fn validate_age(n : Int) -> Validated[Nel[String], Int] {
  if n < 18 {
    Invalid(Nel::new("must be 18 or older"))
  } else {
    Valid(n)
  }
}

struct User { username : String; age : Int }

fn register(username : String, age : Int) -> Validated[Nel[String], User] {
  map2(
    validate_username(username),
    validate_age(age),
    fn(u, a) { { username: u, age: a } },
  )
}

// Both errors reported together:
// register("", 15) ==
//   Invalid(Nel { head: "username must not be empty",
//                 tail: ["must be 18 or older"] })
```

## Validator API with FieldError

For structured form validation with field paths:

```moonbit
// Build a reusable validator for a username field
let username_validator =
  non_empty()
    .zip(max_length(20))
    .map(fn(pair) { pair.0 })
    |> Validator::new
    |> fn(v) { v.at_field("username") }

// Running it:
// username_validator.run("") ==
//   Invalid(Nel { head: FieldError { path: ["username"],
//                                    message: "must be non-empty" }, ... })
```

## API Reference

### Core types

| Type | Description |
|------|-------------|
| `Validated[E, A]` | `Valid(A)` or `Invalid(E)` — like `Result` but accumulates errors |
| `Nel[T]` | Non-empty list; canonical error accumulator |
| `Validator[I, E, A]` | Reusable `(I) -> Validated[E, A]` with combinators |
| `FieldError[M]` | Error with a `path : Array[String]` and `message : M` |

### Combinators

| Function | Description |
|----------|-------------|
| `map2(va, vb, f)` | Combine two `Validated` values; accumulate errors |
| `map3(va, vb, vc, f)` | Combine three `Validated` values |
| `ap(vf, va)` | Applicative apply |
| `sequence(xs)` | `Array[Validated[E,A]] -> Validated[E, Array[A]]` |
| `traverse(xs, f)` | Map then sequence |

### Conversions

| Function | Description |
|----------|-------------|
| `to_result(v)` | `Validated -> Result` |
| `from_result(r)` | `Result -> Validated` |
| `to_option(v)` | `Validated -> Option` (discards error) |
| `from_option(opt, err)` | `Option -> Validated` |
| `attempt(f)` | Catch a raising function into `Validated[Nel[E], A]` |
| `attempt_into(f, wrap)` | Like `attempt` with a custom error wrapper |

### Validated helpers

| Function | Description |
|----------|-------------|
| `map(v, f)` | Transform success value |
| `map_error(v, f)` | Transform error value |
| `fold(v, on_invalid, on_valid)` | Eliminate a `Validated` |
| `is_valid(v)` / `is_invalid(v)` | Predicates |
| `get_or_else(v, default)` | Extract value or fall back |
| `or_else(v, alt)` | Try alternative when `Invalid` |

### Built-in validators

| Function | Description |
|----------|-------------|
| `non_empty()` | String must not be empty |
| `min_length(n)` | String length ≥ n |
| `max_length(n)` | String length ≤ n |
| `in_range(lo, hi)` | Int in `[lo, hi]` |

### Validator methods

| Method | Description |
|--------|-------------|
| `Validator::new(f)` | Lift a function to a `Validator` |
| `v.run(input)` | Execute the validator |
| `v.map(f)` | Transform success output |
| `v.and_then(f)` | Sequential composition |
| `v.zip(other)` | Parallel composition (accumulates errors) |
| `v.at_field(name)` | Prefix all `FieldError` paths with `name` |

## Inspiration

- [Cats `Validated`](https://typelevel.org/cats/datatypes/validated.html) (Scala)
- [Haskell `Validation`](https://hackage.haskell.org/package/validation)

## Release workflow notes

`release-pr` (`.github/workflows/release.yml`) uses `RELEASE_PR_TOKEN` when available.

- `RELEASE_PR_TOKEN` (recommended): Personal Access Token or GitHub App token with permission to create pull requests.
- `GITHUB_TOKEN` (fallback): used when `RELEASE_PR_TOKEN` is not set.

## License

MIT
