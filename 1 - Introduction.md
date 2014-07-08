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

Functions enable a simple form of abstraction which can yield great productivity gains. However, functional programming in JavaScript has its own disadvantages: JavaScript is verbose, untyped, and lacks powerful forms of abstraction.

PureScript is a programming language which aims to address these issues. It features lightweight syntax, which allows us to write very expressive code which is still clear and readable. It uses a rich type system to support powerful abstractions. It also generates fast, understandable code, which is important when interoperating with JavaScript, or other languages which compile to JavaScript. All in all, I hope to convince you that PureScript strikes a very practical balance between the theoretical power of purely functional programming, and the fast-and-loose programming style of JavaScript.
    
## The Power of Types

The debate over statically typed languages versus dynamically typed languages is well-documented. In this book, I will try to convince you (or reaffirm your belief) that static types are not only a means of gaining confidence in the correctness of your programs, but also an aid to development in their own right. Refactoring a large body of code in JavaScript can be difficult when using any but the simplest of abstractions, but an expressive type system together with a type checker can even make refactoring into an enjoyable, interactive experience.

In addition, the safety net provided by a type system enables more advanced forms of abstraction. In fact, PureScript provides a powerful form of abstraction which is fundamentally type-driven: type classes, made popular in the functional programming language Haskell.

## Polyglot Web Programming

Functional programming has its success stories - applications where it has been particularly successful: data analysis, parsing, compiler implementation, generic programming, parallelism, to name a few.

It would be possible to practice end-to-end application development in a functional language like PureScript. PureScript provides the ability to import existing JavaScript code, by providing types for its values and functions, and then to use those functions in regular PureScript code. We'll see this approach later in the book.

However, one of PureScript's strengths is its interoperability with other languages which target JavaScript. Another approach would be to use PureScript for a subset of your application's development, and to use one or more other languages to write the rest of the JavaScript.

Here are some examples:

- Core logic written in PureScript, with the user interface written in JavaScript.
- Application written in JavaScript or another compile-to-JS language, with tests written in PureScript.
- PureScript used to automate user interface tests for an existing application.

In this book, I'll focus on solving small problems with PureScript. The solutions could be integrated into a larger application, but we will also look at how to call PureScript code from JavaScript, and vice versa.

## Prerequisites

The software requirements for this book are minimal: the first chapter will guide you through setting up a development environment from scratch, and the tools we will use are available in the standard repositories of most modern operating systems.

The PureScript compiler itself can either be built from source (on any system running an up-to-date installation of the Haskell Platform) or downloaded as a binary distribution for Linux, MacOS or Windows.

I will assume no prior knowledge of these tools, but any prior familiarity with common tools from the JavaScript ecosystem, such as NPM, Grunt, and Bower, will be beneficial if you wish to customize the standard setup to your own needs.

No prior knowledge of functional programming is required, but it certainly won't hurt. New ideas will be accompanied by practical examples, so you should be able to form an intuition for the concepts from functional programming that we will use.

## How to Read This Book

The chapters in this book are largely self contained. A beginner with little functional programming experience would be well-advised, however, to work through the chapters in order. The first few chapters lay the groundwork required to understand the material later on in the book. A reader who is comfortable with the ideas of functional programming (especially one with experience in a strongly-typed language like ML or Haskell) will probably be able to gain a general understanding of the code in the later chapters of the book without reading the preceding chapters.

Each chapter will focus on a single practical example, providing the motivation for any new ideas introduced. Each chapter will include exercises, which together with the code samples provided, will result in a full solution to the original motivating problem. 

Code samples will appear in a monospaced font, as follows:

```
module Example where

main = Debug.Trace.trace "Hello, World!"
```

You can either type these in by hand (recommended for shorter code samples), or download content from the book's website at [https://github.com/paf31/purescript-book](https://github.com/paf31/purescript-book).

Commands which should be typed at the command line will be preceded by a dollar symbol:

```
$ psc src/Main.purs
```

Usually, these commands will be tailored to Linux/Mac OS users, so Windows users may need to make small changes such as modifying the file separator, or replacing shell built-ins with their Windows equivalents.

Commands which should be typed at the `psci` interactive mode prompt will be preceded by an angle bracket:

```
> 1 + 2
3
```

Each chapter will contain exercises, labelled with their difficulty level. It is strongly recommended that you attempt the exercises in each chapter to fully understand the material.

## Getting Help

If you get stuck at any point, there are a number of resources available online for learning PureScript:

- The PureScript IRC channel is a great place to chat about issues you may be having. Point your IRC client at irc.freenode.net, and connect to the #purescript channel.
- The PureScript website ([http://purescript.org](http://purescript.org)) contains blog posts written by the PureScript developers, as well as links to videos and other resources for beginners.
- The PureScript compiler documentation ([http://docs.purescript.org](http://docs.purescript.org)) contains simple code examples for the major features of the language.
- Try PureScript! is a website which allows users to compile PureScript code in the web browser, and contains several simple examples of code.

## About the Author

I am the original developer of the PureScript compiler. I'm based in Los Angeles, California, and started programming at an early age in BASIC on an 8-bit personal computer, the Amstrad CPC. Since then I have worked professionally in a variety of programming languages (Java, Scala, C#, F#).

Not long into my professional career, I began to appreciate functional programming and its connections with mathematics, and fell in love with the Haskell programming language.

I started working on the PureScript compiler in response to my experience with JavaScript. I found myself using functional programming techniques that I had picked up in languages like Haskell, but wanted a more principled environment in which to apply them. Solutions at the time included various attempts to compile Haskell to JavaScript while preserving its semantics (Fay, Haste, GHCJS), but I was interested to see how successful I could be by approaching the problem from the other side - attempting to keep the semantics of JavaScript, while enjoying the syntax and type system of a language like Haskell.

I maintain a blog at [http://functorial.com](http://functorial.com), and can be reached on Twitter at @paf31.

## Acknowledgements

I would like to thank the many contributors who helped PureScript to reach its current state. Without the huge collective effort which has been made on the compiler, tools, libraries, documentation and tests, the project would certainly have failed. 
