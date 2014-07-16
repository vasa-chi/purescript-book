# Functions and Records

## Chapter Goals

This chapter will introduce two building blocks of PureScript programs: functions and records. In addition, we'll see how to structure PureScript programs, and how to use types as an aid to program development.

We will build a simple phone-book application to manage a list of phone contacts. This code will introduce some new ideas from the syntax of PureScript.

The front-end of our application will be the interactive mode `psci`, but it would be possible to build on this code to write a front-end in Javascript.

## Project Setup

Create a new file `src/Data/PhoneBook.purs`. It should start with its module name and any imports, as before:

```
module Data.PhoneBook where

import Data.List
```

Here, we import the `Data.List` module, which is provided by the `purescript-lists` package which we installed using Bower. It contains a few functions which we will need for working with linked lists.

## Defining Our Types

A good first step when tackling a new problem in PureScript is to write out type definitions for any values you will be working with. First, let's define a type for records in our phone book:

```
type Entry = { firstName :: String, lastName :: String, phone :: String }
```

This defines a _type synonym_ called `Entry` - the type `Entry` is synonymous with the type on the right of the equals symbol: a record type with three fields: `firstName`, `lastName` and `phone`, all of which are expected to be strings.

Now let's define a second type synonym, for a phone book data structure, which will simply be stored as a linked list of entries:

```
type PhoneBook = List Entry
```

Note that just like function application, type constructors are applied to other types simply by juxtaposition: the type `List Entry` is in fact the generic type `List` _applied_ to the type `Entry` - it is a list of entries.

## Displaying Phone Book Entries

Let's write our first function, which will render a phone book entry as a string. We start by giving the function a type. This is optional, but good practice, since it acts as a form of documentation:

```
showEntry :: Entry -> String
```

This type signature says that `showEntry` is a function, which takes an `Entry` as an argument and returns a `String`. Next follows the code for `showEntry`:

```
showEntry entry = entry.lastName ++ ", " ++ 
                  entry.firstName ++ ": " ++ 
                  entry.phone
```

This function works by concatenating the three fields of the `Entry` record into a single string. Fields are accessed with a dot, followed by the field name. In PureScript, string concatenation uses the double-plus operator (`++`) instead of a single plus, as in Javascript. Note also that the `entry` name is brought into scope by typing it on the left hand side of the equals symbol.

## Test Early, Test Often

The `psci` interactive mode allows for rapid prototyping with immediate feedback, so let's use it to verify that our first function behaves as expected.

First, build the code you've written:

```
$ grunt
```

Next, load `psci`, and use the `:i` command to import your new module:

```
$ psci

> :i Data.PhoneBook
```

We can create an entry by using a record literal, just like in JavaScript. Bind it to a name with a `let` expression:

```
> let example = { firstName: "John", lastName: "Smith", phone: "555-555-5555" }
```

(don't forget to terminate the expression with Ctrl+D). Now, try applying our function to the example:

```
> showEntry example

"Smith, John: 555-555-5555"
```

Congratulations! You've just written and executed your first PureScript function.

## Creating Phone Books

Now let's write some utility functions for working with phone books. We will need a value which represents an empty phone book: an empty list.

```
emptyBook :: PhoneBook
emptyBook = empty
```

We will also need a function for inserting a value into an existing phone book. We will call this function `insertEntry`. Start by giving its type:

```
insertEntry :: Entry -> PhoneBook -> PhoneBook
```

This type signature says that `insertEntry` takes an `Entry` as its first argument, and a `PhoneBook` as a second argument, and returns a new `PhoneBook`. There are two things worth mentioning here:

- We don't modify the existing `PhoneBook` directly. Instead, we return a new `PhoneBook` which contains the same data. As such, `PhoneBook` is an example of a _persistent data structure_. This is an important idea in PureScript - mutation is a side-effect of code, and inhibits our ability to reason effectively about its behaviour, so we prefer pure functions and immutable data where possible.
- Functions in PureScript take exactly one argument. While it looks like the `insertEntry` function takes two arguments, it is in fact an example of a _curried function_. The `->` operator in the type of `insertEntry` associates to the right, so the compiler in fact parses the type as `Entry -> (PhoneBook -> PhoneBook)`. That is, `insertEntry` takes a single argument, an `Entry`, and returns a new function, which in turn takes a single `PhoneBook` argument and returns a new `PhoneBook`. We'll cover this idea in more depth in the next chapter.

To implement `insertEntry`, we can use the `Cons` function from `Data.List`. To see its type, open `psci` and use the `:t` command:

```
$ psci

> :t Data.List.Cons

forall a. a -> Data.List.List a -> Data.List.List a
```

This type signature says that `Cons` takes a value of some type `a`, and a list of elements of type `a`, and returns a new list with entries of the same type. In our case, we have two pieces of data: an `Entry`, and a `PhoneBook`. But `PhoneBook` is just a synonym for `List Entry`, so if we choose `Entry` for the type `a`, we can apply `Cons` and get a new `List Entry`. But again, that's just the same thing as a `PhoneBook`, which is exactly what we wanted!

Here is our implementation of `insertEntry`:

```
insertEntry entry book = Cons entry book
```

This brings the two names `entry` and `book` into scope, on the left hand side of the equals symbol, and then applies the `Cons` function to create the result.

## What's Your Number?

The last function we need to implement for our minimal phone book application will look up a person by name and return the correct `Entry`. This will be a nice application of building programs by composing small functions - a key idea from functional programming.

The key idea is that we can first filter the phone book, keeping only those entries with the correct first and last names. Then we can simply return the head (i.e. the first element) of the resulting list.

With this high-level specification of our approach, we can calculate the type of our function. First open `psci`, and find the types of the `filter` and `head` functions:

```
$ psci

> :t Data.List.filter

forall a. (a -> Prim.Boolean) -> Data.List.List a -> Data.List.List a

:t Data.List.head

forall a. Data.List.List a -> Data.Maybe.Maybe a
```

Let's pick apart these two types to understand their meaning.

`filter` works over lists of some unspecified element type `a`. It takes a function as its argument, which takes a list element and returns a Boolean value as a result. `filter` returns another function which takes a `List` and returns another `List`. Note that `filter` is another example of a curried function.

`head` takes a `List` as its argument, and returns a type we haven't seen before: `Maybe a`. `Maybe a` represents an optional value of type `a`, and provides a type-safe alternative to using `null` to indicate a missing value in languages like Javascript. We will see it again in more detail in later chapters. 

Putting these facts together, a reasonable type signature for our function, which we will call `findEntry`, is:

```
findEntry :: String -> String -> PhoneBook -> Maybe Entry
```

This type signature says that findEntry takes two strings, the first and last names, and a `PhoneBook`, and returns an optional `Entry`. The optional result will contain a value only if the name is found in the phone book.

Here is the definition of `findEntry`:

```
findEntry firstName lastName book = head (filter filterEntry book)
  where
  filterEntry :: Entry -> Boolean
  filterEntry entry = entry.firstName == firstName && entry.lastName == lastName
```

Let's go over this code step by step.

`findEntry` brings three names into scope: `firstName`, and `lastName`, both representing strings, and `book`, a `PhoneBook`.

The right hand side of the definition combines the `filter` and `head` functions: first, the list of entries is filtered, and the `head` function is applied to the result.

The predicate function `filterEntry` is defined as an auxiliary declaration inside a `where` clause. This way, the `filterEntry` function is available inside the definition of our function, but not outside it. Also, it can depend on the arguments to the enclosing function, which is essential here because `filterEntry` uses the `firstName` and `lastName` arguments to filter the specified `Entry`.

Note that, just like for top-level declarations, it was not necessary to specify a type signature for `filterEntry`. However, doing so is recommended as a form of documentation.

## Tests, Tests, Tests ...

Now that we have the core of a working application, let's try it out using `psci`.

```
$ psci

> :i Data.PhoneBook 
```

Let's first try looking up an entry in the empty phone book (we obviously expect this to return an empty result):

```
> findEntry "John" "Smith" emptyBook

Error in declaration main
No instance found for Prelude.Show (Data.Maybe.Maybe Data.PhoneBook.Entry<>)
```

Oh no, our first error! Not to worry, this error simply means that `psci` doesn't know how to print a value of type `Entry` as a String. 

The return type of `findEntry` is `Maybe Entry`, which we can convert to a String by hand. 

Our `showEntry` function expects an argument of type `Entry`, but we have a value of type `Maybe Entry`. Remember that this means that the function returns an optional value of type `Entry`. What we need to do is apply the `showEntry` function if the optional value is present, and propagate the missing value if not.

Fortunately, the Prelude module provides a way to do this. The `<$>` operator can be used to lift a function over an appropriate type constructor like `Maybe` (we'll see more on this function, and others like it, later in the book, when we talk about Functors):

```
> showEntry <$> findEntry "John" "Smith" emptyBook

Nothing
```

That's better - the return value `Nothing` indicates that the optional return value does not contain a value - just as we expected.

For ease of use, we can create a function which prints an `Entry` as a String, so that we don't have to use `showEntry` every time:

```
> let printEntry firstName lastName book = showEntry <$> findEntry firstName lastName book
```

Now let's create a non-empty phone book, and try again. We'll reuse our example entry from earlier:

```
> let john = { firstName: "John", lastName: "Smith", phone: "555-555-5555" }

> let book1 = insertEntry john emptyBook

> printEntry "John" "Smith" book1

Just ("Smith, John: 555-555-5555")
```

This time, the result contained the correct value. Try defining a phone book `book2` with two names by inserting another name into `book1`, and look up each entry by name.

## Exercises

1. (Easy) Test your understanding of the `findEntry` function by writing down the types of each of its major subexpressions. For example, the type of the `head` function as used is specialized to `List Entry -> Maybe Entry`.
1. (Easy) Write a function which looks up an `Entry` given a phone number, by reusing the existing code in `findEntry`. Test your function in `psci`.
1. (Moderate) Write a function which tests whether a name appears in a `PhoneBook`, returning a Boolean value. _Hint_: Use `psci` to find the type of the `Data.List.null` function, which test whether a list is empty or not.
1. (Difficult) Write a function `removeDuplicates` which removes duplicate phone book entries with the same first and last names. _Hint_: Use `psci` to find the type of the `Data.List.nubBy` function, which removes duplicate elements from a list based on an equality predicate.

## Conclusion

In this chapter, we set up a development environment from scratch, and written our first useful PureScript library.

We've covered several new functional programming concepts:

- The importance of immutable data and pure functions.
- How to use the interactive mode `psci` to experiment with functions and test ideas.
- The role of types as both a correctness tool, and an implementation tool.
- The use of curried functions to represent functions of multiple arguments.
- Creating programs from smaller components by composition.
- Structuring code neatly using `where` expressions.
- How to avoid null values by using the `Maybe` type.

In the following chapters, we'll build on these ideas.
