# Introduction

## Functional JavaScript

Functional programming techniques have been making appearances in JavaScript for some time now:

- Libraries such as [UnderscoreJS](http://underscorejs.org) allow the developer to leverage tried-and-trusted functions such as `map`, `filter` and `reduce` to create larger programs from smaller programs by composition:

    ```
    var sumOfPrimes = 
        _.chain(_.range(1000))
         .filter(isPrime)
         .reduce(function(x, y) { 
             return x + y; 
         })
         .value();
    ```

- Asynchronous programming in NodeJS leans heavily on functions as first-class values to define callbacks.

    ```
    require('fs').readFile(sourceFile, function (error, data) {
      if (!error) {
        require('fs').writeFile(destFile, data, function (error) {
          if (!error) {
            console.log("File copied");
          }
        });
      }
    });
    ```

- 

Functions enable a simple form of abstraction which can yield great productivity gains. However, functional programming in JavaScript has its own disadvantages:

- JavaScript is verbose

    Functional programming encourages the use of small composable functions, so lightweight syntax for things like function abstraction and function application becomes very important. In JavaScript, every function abstraction requires at least 12 characters (`function() { ... }`), and this can quickly make functional code difficult to read.

- JavaScript is untyped

    The debate over statically typed languages versus dynamically typed languages is well-documented. In this book, I will try to convince you (or reaffirm your belief) that static types are not only a means of gaining confidence in the correctness of your programs, but also an aid to development in their own right. Refactoring a large body of code in JavaScript can be difficult when using any but the simplest of abstractions, but an expressive type system together with a type checker can even make refactoring into an enjoyable, interactive experience. 

- JavaScript lacks powerful forms of abstraction

    JavaScript supports simple forms of abstraction such as prototypes, and of course, function abstraction. With the safety net provided by a type system, more advanced forms of abstraction become possible. In fact, PureScript provides a powerful form of abstraction which is fundamentally type-driven: type classes, made popular in the functional programming language Haskell. 

## The Power of Types

## Prerequisites

## How to Read This Book

## About PureScript

## Getting Help

## Acknowledgements
