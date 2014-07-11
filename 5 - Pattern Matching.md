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
gcd n m | n > m = gcd (n - m) m
gcd n m         = gcd n       (m - n)
```

This algorithm is called the Euclidean Algorithm. If you search for its definition online, you will likely find a set of mathematical equations which look a lot like the code above. This is one benefit of pattern matching: it allows you to define code by cases, writing simple, declarative code which looks like a specification of a mathematical function.

A function written using pattern matching works by pairing sets of conditions with their results. The expressions on the left of the equals sign are called patterns, and describe which conditions the arguments must satisfy before the alternative on the right of the equals sign should be evaluated and returned.

For example, the first line states that if the second argument is zero, then the result is just the value of the first argument.

Note that patterns can bind values to names - each line in the example binds one or both of the names `n` and `m` to the input values. As we learn about different kinds of patterns, we will see that different types of patterns correspond to different ways to choose names from the input arguments.

The third line contains another type of condition: the expression on the right of the pipe is called a _guard_. It is a boolean-valued expression which must be satisfied in addition to the constraints imposed by the patterns. In this case, the extra condition imposed is that the first argument is strictly larger than the second.

## Exercises

1. (Easy) Write the factorial function using pattern matching. _Hint_. Consider the two cases zero and non-zero inputs.
1. (Medium) Look up _Pascal's Rule_ for computing binomial coefficients. Use it to write a function which computes binomial coefficients using pattern matching.

## Matching Arrays

## Matching Objects

## Algebraic Data Types

## Conclusion
