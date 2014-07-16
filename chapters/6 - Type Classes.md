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

The `Num` type class identifies those types which support numeric operators such as addition, subtraction, multiplication and division. It is provided to abstract over those operators, so that they can be reused where appropriate.

_Note_: Just like the `Eq` and `Ord` type classes, the `Num` type class has special support in the PureScript compiler, so that simple expressions such as `1 + 2 * 3` get translated into simple JavaScript, as opposed to function calls which dispatch based on a type class implementation.

```
class Num a where
  (+) :: a -> a -> a
  (-) :: a -> a -> a
  (*) :: a -> a -> a
  (/) :: a -> a -> a
  (%) :: a -> a -> a
  negate :: a -> a
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

If the `Monoid` type class identifies those types which act as the result of a fold, then the `Foldable` type class identifies those type constructors which can be used as the source of a fold.

The `Foldable` type class is provided in the `purescript-foldable-traversable` package, which also contains instances for some standard containers such as arrays and `Maybe`.

The type signatures for the functions belonging to the `Foldable` class are a little more complicated than the ones we've seen so far:

```
class Foldable f where
  foldr :: forall a b. (a -> b -> b) -> b -> f a -> b
  foldl :: forall a b. (b -> a -> b) -> b -> f a -> b
  foldMap :: forall a m. (Monoid m) => (a -> m) -> f a -> m
```

It is instructive to specialize to the case where `f` is the array type constructor. In this case, we can replace `f a` with `[a]` for any a, and we notice that the types of `foldl` and `foldr` become the types that we saw when we first encountered folds over arrays.

What about `foldMap`? Well, that becomes `forall a m. (Monoid m) => (a -> m) -> [a] -> m`. This type signature says that we can choose any monoid for our result type. If we provide a function which turns our array elements into values in that monoid, then we can accumulate over our array using the structure of the monoid, and return a single value.

Let's try out `foldMap` in `psci`:

```
> :i Data.Foldable

> foldMap show [1, 2, 3, 4, 5]
"12345"
```

Here, we choose the String monoid, which concatenates strings together, and the `show` function which renders a Number as a string. Then, passing in an array of Numbers, we see that the results of `show`ing each number have been concatenated into a single String.

But arrays are not the only types which are foldable. `purescript-foldable-traversable` also defines `Foldable` instances for types like `Maybe` and `Tuple`, and other libraries like `purescript-lists` define `Foldable` instances for their own data types. `Foldable` abstracts the concept of an ordered container.

### Functor, and Type Class Laws

The Prelude also defines a collection of type classes which are enable a functional style of programming with side-effects in PureScript: `Functor`, `Applicative` and `Monad`. We will cover these abstractions later in the book, but for now, let's look at the definition of the `Functor` type class, which we have seen already in the form of the lifting operator `<$>`:

```
class Functor f where
  (<$>) :: forall a b. (a -> b) -> f a -> f b
```

The operator `<$>` allows a function to be "lifted" over a data structure. The precise definition of the word "lifted" here depends on the data structure in question, but we have already seen its behavior for some simple types:

```
> :i Data.Array
> (\n -> n < 3) <$> [1, 2, 3, 4, 5]
  
[true, true, false, false, false]

> :i Data.Maybe
> Data.String.length <$> Just "testing"
  
Just (7)
```

How can we understand the meaning of the `<$>` operator, when it acts on many different structures, each in a different way?

Well, we can build an intuition that the `<$>` operator applies the function it is given to each element of a container, and builds a new container from the results, with the same shape as the original. But how do we make this concept precise?

Type class instances for `Functor` are expected to adhere to a set of _laws_, called the _Functor laws_:

- `id <$> xs = xs`
- `g <$> (f <$> xs) = (g <<< f) <$> xs`

The first law states that lifting the identity function over a structure just returns the original structure. This makes sense since the identity function does not modify its input.

The second law states that mapping one function over a structure, and then mapping a second, is the same thing as mapping the composition of the two functions over the structure.

Whatever "lifting" means in the general sense, it should be true that any reasonable definition of lifting a function over a data structure should obey these rules. 

Many standard type classes come with their own set of similar laws. The laws given to a type class give structure to the functions of that type class and allow us to study its instances in generality. The interested reader can research the laws ascribed to the standard type classes that we have seen already.

## Exercises

1. (Easy) The following algebraic data type represents a complex number:

        data Complex = Complex 
          { real :: Number
          , imaginary :: Number 
          }
          
  Define `Show` and `Eq` instances for `Complex`.
1. (Medium) The following type defines a type of non-empty arrays of elements of type `a`:

        data NonEmpty a = NonEmpty a [a]
        
  Write a `Semigroup` instance for non-empty arrays by reusing the `Semigroup` instance for `[]`.
1. (Medium) Write a `Functor` instance for `NonEmpty`.
1. (Difficult) Write a `Foldable` instance for `NonEmpty`.

## Type Annotations

Types of functions can be constrained by using type classes. Here is an example: suppose we want to write a function which tests if three values are equal, by using equality defined using an `Eq` type class instance.

```
threeAreEqual :: forall a. (Eq a) => a -> a -> a -> Boolean
threeAreEqual a1 a2 a3 = a1 == a2 && a2 == a3
```

The type declaration looks like an ordinary polymorphic type defined using `forall`. However, there is a type class constraint in parentheses, separated from the rest of the type by a double arrow `=>`.

This type says that we can call `threeAreEqual` with any choice of type `a`, as long as there is an `Eq` instance available for `a` in one of the imported modules.

Constrained types can contain several type class instances, and the types of the instances are not restricted to simple type variables. Here is another example which uses `Ord` and `Show` instances to compare two values:

```
showCompare :: forall a. (Ord a, Show a) => a -> a -> String
showCompare a1 a2 | a1 < a2 = show a1 ++ " is less than " ++ show a2
showCompare a1 a2 | a1 > a2 = show a1 ++ " is greater than " ++ show a2
showCompare a1 a2 = show a1 ++ " is equal to " ++ show a2
```

There is an important restriction which applies when using functions which are constrained by a type class: the PureScript compiler will not infer a type which is constrained - a type annotation must be provided.

To see this, try using one of the standard type classes like `Num` in `psci`:

```
> :t \x -> x + x

Error in declaration it
No instance found for Prelude.Num u2
```

Here, we try to find the type of a function which doubles a number by using the type's `Num` instance, but `psci` will not infer a constrained type for the function, and so reports that it was unable to find a type class instance for an unknown type.

Instead, we must give a type signature, either as a type declaration for a top-level function declaration, or using the `::` operator:

```
> :t \x -> x + (x :: Number)

Prim.Number -> Prim.Number
```
  
## Overlapping Instances

PureScript has another rule regarding type class instances, called the _overlapping instances rule_. Whenever a type class instance is required at a function call site, PureScript will use the information inferred by the type checker to choose the correct instance. At that time, there must be exactly one appropriate instance for that type.

To demonstrate this, we can try creating two conflicting type class instances for an example type. In the following code, we create two overlapping `Show` instances for the type `T`:

```
module Overlapped where

data T = T

instance showT1 :: Show T where
  show _ = "Instance 1"
  
instance showT2 :: Show T where
  show _ = "Instance 2"
```

This module will compile with no errors. However, if we open it in `psci` and try to find a `Show` instance for the type `Overlapped`, the overlapping instances rule will be enforced, resulting in an error:

```
> show T
  
Compiling Overlapped
Error in declaration it
Overlapping instances found for Prelude.Show Overlapped.T
```

The overlapping instances rule is enforced so that automatic selection of type class instances is a predictable process. If we allowed two type class instances for a type to exist, then either could be chosen depending on the order of module imports, and that could lead to unpredictable behavior of the program at runtime, which is undesirable.

If it is truly the case that there are two valid type class instances for a type, satisfying the appropriate laws, then a common approach is to define new data types which wrap the existing type. Since different data types are allowed to have different instances under the overlapping instances rule, there is no longer an issue. This approach is taken in PureScript's standard libraries, for example in `purescript-monoids`, where the `Maybe a` type has multiple valid instances for the `Monoid` type class. 

## Instance Dependencies

Just as the implementation of functions can depend on type class instances using constrained types, so can the implementation of type class instances depend on other type class instances. This provides a powerful form of program inference, in which the implementation of a program can be inferred using its types.

For example, consider the `Show` type class. We can write a type class instance to `show` arrays of elements, as long as we have a way to `show` the elements themselves:

```
instance showArray :: (Show a) => Show [a] where
  show xs = "[" ++ go xs ++ "]"
    where
    go [] = ""
    go [x] = show x
    go (x : xs) = show x ++ ", " ++ go xs
```

There is an optimized version of this code included in the PureScript Prelude.

Note that the function `show` is used with various types of input. We are defining `show` to work with inputs of type `[a]`, i.e. arrays of elements of type `a`. However, in the `go` function, we bring the head element of the input into scope with the name `x`, and call `show x`. Here, `show` is applied to an _element_ of type `a`.

When the program is compiled, the correct type class instance for `Show` is chosen based on the inferred type of the argument to `show`, but this complexity is not exposed to the developer.

## Exercises

1. (Easy) Write an `Eq` instance for the type `NonEmpty a` which reuses the instances for `Eq a` and `Eq [a]`.
1. (Medium) Given any type `a` with an instance of `Ord`, we can add a new element "at infinity":

        data Extended a = Finite a | Infinite
        
  Write an `Ord` instance for `Extended a` which reuses the `Ord` instance for `a`.
1. (Difficult) Given an type constructor `f` which defines an ordered container (and so has a `Foldable` instance), we can create a new container type which includes an extra element at the front:

        data OneMore f a = OneMore a (f a)
        
  The container `OneMore f` is also has an ordering, where the new element comes before any element of `f`. Write a `Foldable` instance for `OneMore f`:
  
        instance foldableOneMore :: (Foldable f) => Foldable (OneMore f) where
          ...

## Multi Parameter Type Classes

It's not the case that a type class can only take a single type as an argument. This is the most common case, but in fact, a type class can be parameterized by _zero or more_ type arguments.

Let's see an example of a type class with two type arguments.

```
module Stream where

import Data.Maybe
import Data.Tuple
import Data.String

class Stream list element where
  uncons :: list -> Maybe (Tuple element list)

instance streamArray :: Stream [a] a where
  uncons [] = Nothing
  uncons (x : xs) = Just (Tuple x xs)

instance streamString :: Stream String String where
  uncons "" = Nothing
  uncons s = Just (Tuple (take 1 s) (drop 1 s))
```

The `Stream` module defines a class `Stream` which identifies types which look like streams of elements, where elements can be pulled from the front of the stream using the `uncons` function.

Note that the `Stream` type class is parameterized not only by the type of the stream itself, but also by its elements. This allows us to define type class instances for the same stream type but different element types.

The module defines two type class instances: an instance for arrays, where `uncons` removes the head element of the array using pattern matching, and an instance for String, which removes the first character from a String.

We can write functions which work over arbitrary streams. For example, here is a function which accumulates a result based on the elements of a stream:

```
foldStream :: forall list element r. (Stream list element) => (element -> r -> r) -> list -> r -> r
foldStream f list r =
  case uncons list of
    Nothing -> r
    Just (Tuple head tail) -> foldStream f tail (f head r)
```

## Nullary Type Classes

We can even define type classes with zero type arguments! These correspond to compile-time assertions about our functions, allowing us to track global properties of our code in the type system.

For example, suppose we want to track the use of partial functions using the type system. We can define a type class `Partial` with no type arguments, and annotate all partial functions with a `Partial` constraint:

```
module Partial where

class Partial

head :: forall a. (Partial) => [a] -> a
head (x : _) = x

tail :: forall a. (Partial) => [a] -> [a]
tail (_ : xs) = xs
```

Note that we do not define an instance for the `Partial` type class in its defining module. Doing so would defeat its purpose: with this definition, attempting to use the `head` function will result in a type error:

```
> Partial.head [1, 2, 3]
  
Error in declaration it
No instance found for Partial.Partial 
```

The user of this library have two options: 

- The user can opt in to partiality in a module by declaring an instance of the `Partial` type class in that module.

        ```
        module Main where
        
        import Partial
        
        instance partial :: Partial
        ```
- Alternatively, the user can republish the `Partial` constraint for all functions making use of partial functions:

        ```
        secondElement :: forall a. (Partial) => [a] -> a
        secondElement xs = head (tail xs)
        ```

## Superclasses

## A Type Class for Hashes

## Conclusion
