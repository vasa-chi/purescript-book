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
- `purescript-strings`

Also create a new module called `Data.Hashable`:

```
module Data.Hashable where

import Data.Maybe
import Data.Tuple
import Data.Either
import Data.String
import Data.Function
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

Just as we can express relationships between type class instances by making an instance dependent on another instance, we can express relationships between type classes themselves using so-called _superclasses_.

We say that one type class is a superclass of another if every instance of the second class is required to be an instance of the first, and we indicate a superclass relationship in the class definition by using a backwards facing double arrow. 

We've already seen one example of a superclass relationship: the `Eq` class is a superclass of `Ord`. For every type class instance of the `Ord` class, there must be a corresponding `Eq` instance for the same type. This makes sense, since in many cases, when the `compare` function reports that two values are incomparable, we often want to use the `Eq` class to determine if they are in fact equal.

In general, it makes sense to define a superclass relationship when the laws for the subclass mention the members of the superclass. For example, it is reasonable to assume, for any pair of `Ord` and `Eq` instances, that if two values are equal under the `Eq` instance, then the `compare` function should return `EQ`. In order words, `a == b` implies `compare a b == EQ`. This relationship on the level of laws justifies the superclass relationship between `Eq` and `Ord`.

Another reason to define a superclass relationship is in the case where there is a clear "is-a" relationship between the two classes. That is, every member of the subclass _is a_ member of the superclass as well.

## Exercises

1. (Easy) The `Action` class is a multi-parameter type class which defines an action of one type on another:

        class (Monoid m) <= Action m a where
          act :: m -> a -> a
          
  (An _action_ is just a function which describes how one type can be used to modify another)
  
  Write down a reasonable set of laws which describe how the `Action` class should interact with the `Monoid` class.
1. (Medium) Write an instance `Action m a => Action m [a]`, where the action on arrays is defined by acting element-wise.
1. (Difficult) Given the following data type, write an instance for `Action m (Self m)`, where the monoid `m` acts on itself by concatenation:

        data Self m = Self m
1. (Medium) Define a nullary type class `Unsafe` and use it to define a version of the `unsafeIndex` function from the `Prelude.Unsafe` module, which uses your constraint to express its lack of type-safety. Use your function to define a function `last` which chooses the last element of an array, and which preserves the `Unsafe` constraint.

## A Type Class for Hashes

In the last section, we will use the work of the rest of the chapter to practical effect, to create a library for hashing data structures.

Note that this library is for demonstration purposes only, and is not intended to provide a robust hashing mechanism.

What properties might we expect of a hash function?

- A hash function should be deterministic, and map equal values to equal hash codes.
- A hash function should distribute its results approximately uniformly over some set of hash codes.

The first property looks a lot like a law for a type class, whereas the second property is more along the lines of an informal contract, and certainly would not be enforceable by PureScript's type system. However, this should provide the intuition for the following type class:

```
type HashCode = Number

class (Eq a) <= Hashable a where
  hash :: a -> Number 
```

with the associated law that `a == b` implies `hash a == hash b`.

We'll spend the rest of this section building a library of instances and functions associated with the `Hashable` type class.

We will need a way to combine hash codes in a deterministic way. For our purposes, the following function will suffice to mix two hash codes and distribute the result over the interval 0-65535.

```
(<#>) :: HashCode -> HashCode -> HashCode
(<#>) h1 h2 = (73 * h1 + 51 * h2) % 65536
```

This user-defined operator can be used infix to combine two hash codes `h1` and `h2` as follows: `h1 <#> h2`.

Let's write a function which uses the `Hashable` constraint to restrict the types of its inputs. One common task which requires a hashing function is to determine if two values hash to the same hash code. The `hashEqual` relation provides such a capability:

```
hashEqual :: forall a. (Hashable a) => a -> a -> Boolean
hashEqual = (==) `on` hash
```

This function uses the `on` function from `Data.Function` to define hash-equality in terms of equality of hash codes, and should read like a declarative definition of hash-equality: two values are "hash-equal" if they are equal after each value has been passed through the `hash` function.

Let's write some `Hashable` instances for some primitive types. Let's start with an instance for strings. We will need some functions from the `Data.String` module, namely `length` and `charCodeAt`. The following `Hashable` instance works by iterating over the characters of the string, and using the `<#>` operator to combine the character codes with an accumulated hash code:

```
instance hashString :: Hashable String where
  hash s = go 0 0
    where
    go :: Number -> HashCode -> HashCode
    go i acc | i >= length s = acc
    go i acc = go (i + 1) acc <#> charCodeAt i s
```

What about an instance for the `Number` type? Well, dealing with the JavaScript `Number` type presents some difficulties, due to the presence of floating point and infinite values, so for demonstration purposes, we will simplify matters by simply hashing the string representation of the number, as computed by `show`:

```
instance hashNumber :: Hashable Number where
  hash n = hash (show n)
```

Note that the type class instance for `Number` necessarily uses the type class instance for `String`.

The instance for the `Boolean` type is even simpler: we can simply assign two static hash codes to the two values of the type:

```
instance hashBoolean :: Hashable Boolean where
  hash false = 0
  hash true  = 1
```

How can we prove that these `Hashable` instances satisfy the type class law that we stated above? We need to make sure that equal values have equal hash codes. In the cases of `String` and `Boolean`, this is simple because there are no strings or boolean values which are equal in the sense of `Eq` but not equal identically.

In the case of numbers, we have to simply convince ourselves that equal numbers have equal string representations, whence we can defer to the proof already given for strings.

What about some more interesting types? Here is a `Hashable` instance for arrays, which combines hashes of the elements of the input array using `<#>`:

```
instance hashArray :: (Hashable a) => Hashable [a] where
  hash [] = 0
  hash (x : xs) = hash x <#> hash xs
```

To prove the type class law in this case, we can use induction on the length of the array. The only array with length zero is `[]`. Any two non-empty arrays are equal only if they have equals head elements and equal tails, by the definition of `Eq` on arrays. By the inductive hypothesis, the tails have equal hashes, and we know that the head elements have equal hashes if the `Hashable a` instance must satisfy the law. Therefore, the two arrays have equal hashes, and so the `Hashable [a]` upholds the type class law as well.

The source code for this chapter includes several other examples of `Hashable` instances, such as instances for the `Maybe` and `Tuple` type.

## Exercises

1. (Easy) Use `psci` to test the hash functions for each of the defined instances.
1. (Easy) Use the `hashEqual` function to write a function which tests if an array has any duplicate elements, using hash-equality as an approximation to value equality. Rememeber to check for value equality using `==` if a duplicate pair is found.
1. (Medium) Write a `Hashable` instance for the following type which upholds the type class law:

    ```
    data Uniform = Uniform Number
    
    instance eqUniform :: Eq Uniform where
      (==) (Uniform u1) (Uniform u2) = u1 % 1.0 == u2 % 1.0 
      (/=) (Uniform u1) (Uniform u2) = u1 % 1.0 /= u2 % 1.0 
    ```
    
  The type `Uniform` and its `Eq` instance represent the type of numbers with the equivalence relation of having equal fractional parts. Prove that the type class law holds for your instance.
1. (Difficult) Prove the type class laws for the `Hashable` instances for `Maybe`, `Either` and `Tuple`.

## Conclusion

In this chapter, we've been introduced to _tyoe classes_, a type-oriented form of abstraction which enables powerful forms of code reuse. We've seen a collection of standard type classes from the PureScript standard libraries, and defined our own library based on a type class for computing hash codes.

This chapter also gave an introduction to the notion of type class laws, a technique for proving properties about code which uses type classes for abstraction. Type class laws are part of a larger subject called _equational reasoning_, in which the properties of a programming language and its type system are used to enable logical reasoning about its programs. This is an important idea, and will be a theme which we will return to throughout the rest of the book.
