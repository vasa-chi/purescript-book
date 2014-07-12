# Pattern Matching

## Chapter Goals

This chapter will introduce two new concepts: algebraic data types, and pattern matching. Pattern matching is a common technique in functional programming and allows the developer to write compact code which expresses potentially complex ideas. Algebraic data types are a feature of the PureScript type system which allow similar expressiveness in the language of types - they are closely related to pattern matching.

The goal of the chapter will be to write a library to describe and manipulate simple vector graphics.

## Project Setup

Create a new project with the following Bower dependencies:

- `purescript-globals`
- `purescript-math`
- `purescript-arrays`
- `purescript-foldable-traversable`

Also create a new module called `Data.Picture`:

```
module Data.Picture where

import Data.Foldable
```

## Simple Pattern Matching

Let's begin by looking at an example. Here is a function which computes the greatest common divisor of two integers using pattern matching:

```
gcd :: Number -> Number -> Number
gcd n 0 = n
gcd 0 n = n
gcd n m = if n > m then gcd (n - m) m else gcd n (m - n)
```

This algorithm is called the Euclidean Algorithm. If you search for its definition online, you will likely find a set of mathematical equations which look a lot like the code above. This is one benefit of pattern matching: it allows you to define code by cases, writing simple, declarative code which looks like a specification of a mathematical function.

A function written using pattern matching works by pairing sets of conditions with their results. The expressions on the left of the equals sign are called patterns, and describe which conditions the arguments must satisfy before the alternative on the right of the equals sign should be evaluated and returned.

For example, the first line states that if the second argument is zero, then the result is just the value of the first argument.

Note that patterns can bind values to names - each line in the example binds one or both of the names `n` and `m` to the input values. As we learn about different kinds of patterns, we will see that different types of patterns correspond to different ways to choose names from the input arguments.

The example code above demonstrates two types of patterns:

- Numeric literals patterns, which match something of type `Number`, only if the value matches exactly.
- Variable patterns, which bind their argument to a name

There are other types of simple patterns:

- String and Boolean literals
- Wildcard patterns, indicated with an underscore (`_`), which match any argument, and which do not bind any names.

Here are two more examples which demonstrate using these simple patterns:

```
fromString :: String -> Boolean
fromString "true" = true
fromString _      = false

toString :: Boolean -> String
toString true  = "true"
toString false = "false"
```

## Guards

In the Euclidean algorithm example, we used an `if .. then .. else` expression to switch between the two alternatives when `m > n` and `m <= n`. Another option in this case would be to use a _guard_.

A guard is a boolean-valued expression which must be satisfied in addition to the constraints imposed by the patterns. Here is the Euclidean algorithm rewritten to use a guard:

```
gcd :: Number -> Number -> Number
gcd n 0 = n
gcd 0 n = n
gcd n m | n > m = gcd (n - m) m 
gcd n m         = gcd n (m - n)
```

In this case, the third line uses a guard to impose the extra condition that the first argument is strictly larger than the second.

As this example demonstrates, guard appear on the left of the equals symbol, separated from the list of patterns by a pipe character (`|`).

## Exercises

1. (Easy) Write the factorial function using pattern matching. _Hint_. Consider the two cases zero and non-zero inputs.
1. (Medium) Look up _Pascal's Rule_ for computing binomial coefficients. Use it to write a function which computes binomial coefficients using pattern matching.

## Matching Arrays

Let's look at ways in which we can match arrays using patterns. There are two types of array pattern: array literal patterns, and cons patterns.

### Array Literal Patterns

Array literal patterns provide a way to match arrays of a fixed length. For example, suppose we want to write a function which treats empty arrays in a special way:

```
isEmpty :: forall a. [a] -> Boolean
isEmpty [] = true
isEmpty _ = false
```

Or another function which treats arrays of length five as special, binding each of its five elements in a different way:

```
takeFive :: [Number] -> Number
takeFive [0, 1, a, b, _] = a * b
takeFive = 0
```

The first pattern only matches arrays with five elements, whose first and second elements are 0 and 1 respectively. In that case, the function returns the produce of the third and fourth elements.

### Cons Patterns

Cons patterns match arrays whose length is at least one. They provide a way to separate the first element (or head) of an array, and the rest (or tail) of the array.

For example, here is a function which sums the squares in an array of numbers:

```
sumOfSquares :: [Number] -> Number
sumOfSquares [] = 0
sumOfSquares (n : ns) = n * n + sumOfSquares ns
```

This function works by separating the input into two cases: empty and non-empty arrays. If the array is empty, then the sum of squares is zero. If not, then we separate the head and tail of the array using a cons pattern, square the head element, and add it to the sum of squares of the tail.

As this example shows, cons patterns are introduced by separating two patterns with a colon: the pattern on the left of the colon matches the array head, and the pattern on the right matches the array tail.

Here is another example. This function finds the sum of all products of adjacent pairs in a list of numbers:

```
sumOfProducts :: [Number] -> Number
sumOfProducts [] = 0
sumOfProducts [_] = 0
sumOfProducts (n : m : ns) = n * m + sumOfProducts (m : ns)
```

This function splits the input into three cases: zero elements, one element, and two or more elements. In the last case, we multiply the first two elements, and recurse on the tail.

## Exercises

1. (Easy) Write a function `allTrue` which determines if all elements of an array of Boolean values are equal to `true`.
2. (Medium) Write a function which replaces the first two elements of an array of Numbers with their sum.

## Matching Records

Just as array literal patterns and cons patterns exist to deconstruct arrays, PureScript provides record patterns to deconstruct record values.

Record patterns look like record literals, but instead of colons to separate labels from expressions, record patterns use equals symbols to separate labels from patterns. For example: this pattern matches any record which contains fields called `name` and `age`, and binds their values to the names `x` and `y` respectively:

```
showPerson :: { name :: String, age :: Number } -> String
showPerson { name = x, age = y } = x ++ " (age " ++ show y ++ ")"
```

## Nested Patterns

Array patterns and record patterns both combine smaller patterns to build larger patterns. For the most part, the examples above have only used simple patterns inside array patterns and record patterns, but it is important to note that patterns can be arbitrarily nested, which allows functions to be defined using conditions on potentially complex data types.

For example, this code combines record and array patterns to match an array of records:

```
type Person = { height :: Number }

totalHeight :: [Person] -> Number
totalHeight [] = 0
totalHeight ({ height = h } : ps) = h + totalHeight ps
```

## Named Patterns

Patterns can be named to bring additional names into scope when using nested patterns. Any pattern can be named by using the `@` symbol. For example, the following code matches any array with one or more elements, but in addition to binding the head of the array to a name, the value of the array itself is bound to the name `arr`:

```
dup :: forall a. [a] -> [a]
dup arr@(x : _) = x : arr
dup [] = []
```

## Exercises

1. (Easy) Write a function which uses record patterns to find a person's city. A Person should be represented as a record which contains an `address` field of type `Address`, and `Address` should contain the `city` field.
1. (Medium) Write a function `flatten` which uses only patterns and the concatenation (`++`) operator to flatten an array of arrays into a singly-nested array. _Hint_: the function should have type `forall a. [[a]] -> [a]`.

## Algebraic Data Types

## Case Statements

## Conclusion
