# Type Classes

## Chapter Goals

This chapter will introduce a powerful form of abstraction which is enabled by PureScript's type system - type classes.

This motivating example for this chapter will be a library for hashing data structures. We will see how the machinery of type classes allow us to hash complex data structures without having to think directly about the structure of the data itself.

We will also see a collection of standard type classes from PureScript's Prelude and standard libraries. PureScript code leans heavily on the power of type classes to express ideas concisely, so it will be beneficial to familiarise yourself with these classes.

## Project Setup

Create a new project with the following Bower dependencies:

- `purescript-maybe`
- `purescript-tuples`
- `purescript-either`

Also create a new module called `Data.Hashable`:

```
module Data.Hashable where

import Data.Maybe
import Data.Tuple
import Data.Either
```

## Show Me!

Our first simple example of a type class is provided by a function we've seen several times already: the `show` function, which takes a value and displays it as a string.

`show` is defined by a type class in the `Prelude` module called `Show`, which is defined as follows:

```
class Show a where
  show :: a -> String
```

This code declares a new _type class_ called `Show`, which is parameterized by a type variable `a`. We say that a type `a` belongs to the type class `Show` if there is a function `show` with the given signature.

A type class _instance_ contains implementations of the functions defined in a type class, for a specific type `a`. For example, here is the definition of the `Show` type class instance for Boolean values, taken from the Prelude:

```
instance showBoolean :: Show Boolean where
  show true = "true"
  show false = "false"
```

This declares a type class instance called `showBoolean` - in PureScript, type class instances are named to aid the readability of the generated JavaScript.

We can try out the `Show` type class in `psci`, by showing a few values with different types:

```
> show true

"true"

> show 1.0

"1"

> show "Hello World"

"\"Hello World\""
```

These examples demonstrate how to `show` values of various primitive types, but we can also `show` values with more complicated types:

```
> i Data.Tuple
> show $ Tuple 1 true
"Tuple (1) (true)"

> :i Data.Maybe
> show $ Just "testing"
"Just (\"testing\")"
```

If we try to show a value of type `Data.Either`, we get an interesting error message:

```
> :i Data.Either
> show $ Left 10
  
Error in declaration it
No instance found for Prelude.Show (Data.Either.Either Prim.String u8)
```

The problem here is not that there is no `Show` instance for the type we intended to `show`, but rather that `psci` was unable to infer the type. This is indicated by the _unknown type_ `u8` in the error message.

We can annotate the expression with a type, using the `::` operator, so that `psci` can choose the correct type class instance:

```
> show (Left 10 :: Either Number String)
  
"Left (10)"
```

## Exercises

1. (Easy) Use the `showShape` function from the previous chapter to define a `Show` instance for the `Shape` type.

## Conclusion
