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

Some types do not have a `Show` instance defined at all. One example of this is the function type `->`. If we try to `show` a function from `Number` to `Number`, we get an appropriate error message from the type checker:

```
> show $ \n -> n + 1
  
Error in declaration it
No instance found for Prelude.Show (Prim.Number -> Prim.Number)
```

## Exercises

1. (Easy) Use the `showShape` function from the previous chapter to define a `Show` instance for the `Shape` type.

## Common Type Classes

In this section, we'll look at some standard type classes defined in the Prelude and standard libraries. These type classes form the basis of many common patterns of abstraction in idiomatic PureScript code, so a basic understanding of their functions is highly recommended.

### Eq

The `Eq` type class defines the equality (`==`) and inequality (`/=`) operators.

```
class Eq a where
  (==) :: a -> a -> Boolean
  (/=) :: a -> a -> Boolean
```

Note that in either case, the two arguments must have the same type: it does not make sense to compare two values of different types for equality.

Try out the `Eq` type class in `psci`:

```
> 1 == 2
false

> "Test" == "Test"
true
```

### Ord

The `Ord` type class defines the `compare` function, which can be used to compare two values, for types which support ordering. The comparison operators `<` and `>` along with their non-strict companions `<=` and `>=`, can be defined in terms of `compare`.

```
data Ordering = LT | EQ | GT

class (Eq a) <= Ord a where
  compare :: a -> a -> Ordering
```

The `compare` function compares two values, and returns an `Ordering`, which has three alternatives:

- `LT` - if the first argument is less than the second.
- `EQ` - if the first argument is equal to (or incomparable with) the second.
- `GT` - if the first argument is greater than the second.

Again, we can try out the `compare` function in `psci`:

Try out the `Eq` type class in `psci`:

```
> compare 1 2
LT

> compare "A" "Z"
LT
```

### Num, Bits and BoolLike

The `Num`, `Bits` and `BoolLike` type classes identifies those types which support numeric, bitwise and boolean operators respectively. They are provided to abstract over those operators, so that they can be reused where appropriate.

_Note_: Just like the `Eq` and `Ord` type classes, the `Num`, `Bits` and `BoolLike` type classes have special support in the PureScript compiler, so that simple expressions such as `1 + 2 * 3` get translated into simple JavaScript, as opposed to function calls which dispatch based on a type class implementation.
```
class Num a where
  (+) :: a -> a -> a
  (-) :: a -> a -> a
  (*) :: a -> a -> a
  (/) :: a -> a -> a
  (%) :: a -> a -> a
  negate :: a -> a
  
class Bits b where
  (&) :: b -> b -> b
  (|) :: b -> b -> b
  (^) :: b -> b -> b
  shl :: b -> Prim.Number -> b
  shr :: b -> Prim.Number -> b
  zshr :: b -> Prim.Number -> b
  complement :: b -> b

class BoolLike b where
  (&&) :: b -> b -> b
  (||) :: b -> b -> b
  not :: b -> b
```

### Semigroups and Monoids

The `Semigroup` type class identifies those types which support a "concatenation operator" `<>`:

```
class Semigroup a where
  (<>) :: a -> a -> a
```

In the Prelude, a `Semigroup` instance is provided for the String type, which corresponds to ordinary string concatenation, but several other standard instances are provided by the `purescript-monoid` and `purescript-arrays` packages.

The `++` concatenation operator, which we have already seen, is provided as an alias for `<>`.

The `Monoid` type class (provided by the `purescript-monoid` package) extends the `Semigroup` type class with the concept of an empty value, called `mempty`:

```
class (Semigroup m) <= Monoid m where
  mempty :: m
```

A `Monoid` type class instance for a type describes how to _accumulate_ a result with that type, by starting with an "empty" value, and combining new results.

The `purescript-monoid` package provides many examples of monoids and semigroups, which we will see throughout the rest of the book.

### Foldable

### Functor, Apply, Applicative, Bind, Monad




## Exercises

1. (Easy) The following algebraic data type represents a complex number:

        data Complex = Complex 
          { real :: Number
          , imaginary :: Number 
          }
          
  Define `Show` and `Eq` instances for `Complex`.
  
## Uniqueness of Instances

## Instance Dependencies

## Multi Parameter Type Classes

## Nullary Type Classes

## Superclasses

## Type Annotations

## A Type Class for Hashes

## Conclusion
