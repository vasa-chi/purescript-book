# Getting Started

## Chapter Goals

In this first chapter, the goal will be to set up a working PureScript development environment, and to write our first PureScript program.

The first program we will write is a simple Hello World application.

## Introduction

Here are the tools we will be using to set up our PureScript development environment:

- `psc` ([http://purescript.org](purescript.org)) - The PureScript compiler itself.
- `npm` ([http://npmjs.org](npmjs.org))- The Node Package Manager, which will allow us to install the rest of our development tools.
- `bower` ([http://bower.io/](bower.io)) - A package manager which is used to version various PureScript packages which we will need.
- `grunt` ([http://gruntjs.com/](gruntjs.com)) - An automation tool which we will use to build our PureScript code.

The first half of the chapter will guide you through installing and configuring these tools. In the second half, we will work on writing some actual code.

## Installing PureScript

The PureScript compiler can be downloaded as a binary distribution for Windows, MacOS or Linux from [http://purescript.org](purescript.org).

Alternatively, if you have a working installation of the Haskell Platform (available from [http://haskell.org/platform](haskell.org/platform)), you can build the PureScript compiler from source. This is the recommended approach if you would like to stay up-to-date with the latest bug fixes and feature additions.

To install from source, first clone the compiler repository:

```
$ git clone git@github.com:/purescript/purescript.git
```

Now create a Cabal sandbox and build the executables:

```
$ cd purescript
$ cabal configure --enable-tests
$ cabal build
```

The compiler and associated executables will usually be placed in the `dist` subdirectory from where you can copy them onto your path.

## Installing Tools

If you do not have a working installation of NodeJS, you should install it from [http://nodejs.org/](nodejs.org/). This should also install the `npm` package manager on your system. Make sure you have `npm` installed and available on your path.

Once you have a working copy of `npm` installed, you will need to install Grunt and Bower. It is usually a good idea to install these globally, so that their command line tools will be available to you regardless of which project you are working in.

```
$ npm install -g grunt-cli bower
```

At this point, you will have all the tools needed to create your first PureScript project.

## Hello, PureScript!

Let's start out simple. We'll use the PureScript compiler `psc` directly to compile a basic Hello World! program. As the chapter progresses, we'll automate more and more of the development process, until we can build our app from scratch including all dependencies with three standard commands.

First of all, create a directory `src` for your source files, and paste the following into a file named `src/Main.purs`:

```
module Main where

import Debug.Trace

main = trace "Hello, World!"
```

This small sample illustrates a few key ideas:

- Every file begins with a module header. A module name consists of one or more capitalized words separated by dots. In this case, only a single word is used, but `My.First.Module` would be an equally valid module name.
- Modules are imported using their full names, including dots to separate the parts of the module name. Here, we import the `Debug.Trace` module, which provides the `trace` function.
- The `main` program is defined as a function application. In PureScript, function application is indicated with whitespace separating the function name from its arguments.

Let's build and run this code. Invoke the following command:

```
$ psc src/Main.purs
```

If everything worked, then you will see a relatively large amount of Javascript emitted onto the console. Instead, let's redirect the output to a file with the `--output` command line option:

```
$ psc src/Main.purs --output dist/Main.js
```

You should now be able to run your code using NodeJS:

```
$ node dist/Main.js
```

If that worked, NodeJS should execute your code, and correctly print nothing to the console. The reason is that we have not told the PureScript compiler the name of our main module!

```
$ psc src/Main.purs --output dist/Main.js --main Main
```

In fact, if your main module is named `Main`, you can omit the module name, and just specify the `--main` flag.

This time, if you run run your code, you should see the words "Hello, World!" printed to the console.

## Removing Unused Code

If you open the `dist/Main.js` file in a text editor, you will see quite a large amount of JavaScript. The reason for this is that the compiler ships with a set of standard functions in a set of modules called the Prelude. The Prelude includes the `Debug.Trace` module that we are using to print to the console.

In fact, almost none of this generated code is being used, and we can remove the unused code with another compiler option:

```
$ psc src/Main.purs --output dist/Main.js --main Main --module Main
```

I've added the `--module Main` option, which tells `psc` only to include JavaScript which is required by the code defined in the `Main` module. This time, if you open the generated code in a text editor, you should see the following:

```
var PS = PS || {};
PS.Debug_Trace = (function () {
    "use strict";
    function trace(s) { 
      return function() {
        console.log(s);
        return {};  
      };
    };
    return {
        trace: trace
    };
})();

var PS = PS || {};
PS.Main = (function () {
    "use strict";
    var Debug_Trace = PS.Debug_Trace;
    var main = Debug_Trace.trace("Hello, World!");
    return {
        main: main
    };
})();

PS.Main.main();
```

If you run this code using NodeJS, you should see the same text printed onto the console.

This illustrates a few points about the way the PureScript compiler generates Javascript code:

- Every module gets turned into a object, created by a wrapper function, which contains the module's exported members.
- PureScript tries to preserve the names of variables wherever possible
- Function applications in PureScript get turned into function applications in JavaScript.
- The main method is run after all modules have been defined, and is generated as a simple method call with no arguments.
- PureScript code does not rely on any runtime libraries. All of the code that is generated by the compiler originated in a PureScript module somewhere which your code depended on.

These points are important, since they mean that PureScript generates simple, understandable code. In fact, the code generation process in general is quite a shallow transformation. It takes relatively little understanding of the language to predict what JavaScript code will be generated for a particular input.

## Automating the Build with Grunt

Now let's set up Grunt to build our code for us, instead of having to type out the PureScript compiler options by hand every time.

Create a file in the project directory called `Gruntfile.js` and paste the following code:

```
module.exports = function(grunt) {

  "use strict";

  grunt.initConfig({

    psc: {
      options: {
        main: "Main",
        modules: ["Main"]
      },
      all: {
        src: ["src/**/*.purs"],
        dest: "dist/Main.js"
      }
    }
  });

  grunt.loadNpmTasks("grunt-purescript");

  grunt.registerTask("default", ["psc:all"]);
};
```

This file defines a Node module, which uses the `grunt` module as a library to define a build configuration. It uses the `grunt-purescript` plugin, which invokes the PureScript compiler and exposes its command line options as JSON properties.

The `grunt-purescript` plugin also provides other useful capabilities, such as the ability to automatically generate Markdown documentation from your code, or generate configuration files for your libraries for the `psci` interactive compiler. The interested reader is referred to the `grunt-purescript` project homepage at [https://github.com/purescript-contrib/grunt-purescript](github.com/purescript-contrib/grunt-purescript).

Install the `grunt` library and the `grunt-purescript` plugin into your local modules directory as follows:

```
$ npm install grunt grunt-purescript@0.5.1
```

With the `Gruntfile.js` file saved, you can now compile your code as follows:

```
$ grunt
>> Created file dist/Main.js.

Done, without errors.
```

## Creating an NPM Package

Now that you've set up Grunt, you don't have to type out compiler commands every time you want to recompile, but more importantly, the end-users of your code don't need to either. However, we've now added an extra step: we need to install a custom set of NPM packages before we can build. 

Let's define an NPM package of our own, which specifies our dependencies.

In the project directory, run the `npm` executable, specifying the `init` subcommand, to initialize a new project:

```
$ npm init
```

You will be asked a variety of questions, at the end of which, a file named `package.json` will be added to the project directory. This file specifies our project properties, and we can add our dependencies as an additional property. Open the file in a text editor, and add the following property to the main JSON object:

```
dependencies: {
  "grunt-purescript": "0.5.1"
}
```

This specifies an exact version of the `grunt-purescript` plugin that we'd like to install.

Now, instead of having to install dependencies by hand, your end-users can simply use `npm` to install everything that is required:

```
$ npm install
```

## Tracking Dependencies with Bower

For our phone book application (the goal of this chapter), we will need a data structure to store contact information. To keep things simple for this introductory chapter, we'll use a simple linked list to store our data.

The `purescript-lists` package contains helper functions for working with linked lists that we will find useful, so let's install it. Just like we did with our `npm` dependencies, we could download this package directly on the command line, by typing:

```
$ bower install purescript-lists#0.0.1
```

This will install version 0.0.1 of the `purescript-lists` library, along with its dependencies.

However, we can set up a `bower.json` file which contains our Bower dependencies, just like we used `npm init` to create `package.json` and control our NPM dependencies.

On the command line, run:

```
$ bower init
```

Just like in the case of NPM, you will be asked a collection of questions, at the end of which, a `bower.json` file will be placed in the project directory. During this process, you will be asked whether you would like to include existing dependencies in the project file. If you select Yes, you should see a section like this in `bower.json`:

```
dependencies: {
  'purescript-lists': '0.0.1'
}
```

Now, your users will not have to specify dependencies by hand, but instead can pull dependendencies by simply invoking:

```
$ bower update
```

Let's update our Grunt script to include dependencies pulled from Bower. Edit `Gruntfile.js` to change the source files line as follows:

```
src: ["src/**/*.purs", "bower_components/**/src/**/*.purs"]
```

This line includes source files from the `bower_components` directory. If you have a customer Bower configuration, you may have to change this line accordingly.

## NPM or Bower?

You may be asking yourself: why do we need to use two package managers? Can't the PureScript libraries be included in the NPM registry?

The PureScript community has standardised on using Bower for PureScript dependencies for a number of reasons:

- PureScript library packages rarely contain JavaScript source code, so are not suitable for deployment into the NPM registry without being compiled first.
- The Bower registry simply maintains a mapping from package names and versions to existing Git repositories, instead of hosting code directly. This allows the community to use existing tools such as GitHub to manage code and releases.
- Bower does not require packages to conform to any particular layout, such as the CommonJS module standard.

Of course, you are free to use any package manager of your choice - the PureScript compiler and tools are not dependent on Bower (or NPM or Grunt, for that matter) in any way.

## Optional: Building CommonJS Modules

The PureScript compiler `psc` generates JavaScript code in a single output file, which is suitable for use in a web browser. There is another option for compilation, called `psc-make`, which can generate a separate CommonJS module for every PureScript module which is compiled. This may be preferable if you are targetting a runtime like NodeJS which supports the CommonJS module standard.

To invoke `psc-make` on the command line, specify the input files, and a directory in which CommonJS modules should be created with the `--output` option:

```
$ psc-make src/Main.purs --output dist/
```

This will create a subdirectory inside the `dist/` directory for every module provided as an input file. If you are using Bower dependencies, don't forget to include source files in the `bower_components/` directory as well!

The `grunt-purescript` plugin also supports compilation using `psc-make`. To use `psc-make` from Grunt: make the following changes in the `Gruntfile.js` file:

- Change the build target from `psc` to `pscMake`.
- Change the destination from a single file `dist/Main.js` to a directory: `dest: "dist/"`
- Change the default task to reference the `pscMake` build target.

Now, the `grunt` command line tool should create a subdirectory under `dist/` for the `Main` module and every one of its dependencies.

## Optional: Using the Interactive Mode

This section is optional, but recommended.

The PureScript compiler also ships with an interactive REPL called `psci`. This can be very useful for testing your code, and experimenting with new ideas.

The `grunt-purescript` plugin can be configured to generate a `psci` configuration for your source files. This saves you the trouble of having to load your modules into `psci` manually.

To set this up, add a new build target to your `Gruntfile.js` file, below the `psc` or `pscMake` target:

```
dotPsci: ["src/**/*.purs", "bower_components/**/src/**/*.purs"]
```

Also, add this target to the default task:

```
grunt.registerTask("default", ["psc:all", "dotPsci"]);
```

Now, if you run `grunt`, a `.psci` file will be generated in the project directory. This file specifies the commands which should be used to configure `psci` when the interactive mode is loaded.

Load `psci` now:

```
$ psci
 ____                 ____            _       _   
|  _ \ _   _ _ __ ___/ ___|  ___ _ __(_)_ __ | |_ 
| |_) | | | | '__/ _ \___ \ / __| '__| | '_ \| __|
|  __/| |_| | | |  __/___) | (__| |  | | |_) | |_ 
|_|    \__,_|_|  \___|____/ \___|_|  |_| .__/ \__|
                                       |_|        

:? shows help

Expressions are terminated using Ctrl+D
> 
```

You can type `:?` to see a list of commands:

```
> :?
The following commands are available:

    :?              Show this help menu
    :i <module>     Import <module> for use in PSCI
    :m <file>       Load <file> for importing
    :q              Quit PSCi
    :r              Reset
    :t <expr>       Show the type of <expr>
```

By pressing the Tab key, you should be able to see a list of all functions available in your own code, as well as any Bower dependencies and the Prelude modules.

Try evaluating a few expressions now (expressions are terminated with Ctrl+D):

```
> 1 + 2
3

> "Hello, " ++ "World!"
"Hello, World!"
```

You can also use `psci` to define functions:

```
> let square x = x * x

> square 10
100
```

Don't worry if the syntax of these examples is unclear right now - it will make more sense as you read through the book.

Finally, you can check the type of an expression by using the `:t` command:

```
> :t true
Prim.Boolean

> :t [1, 2, 3]
[Prim.Number]
```

Try out the interactive mode now. If you get stuck at any point, simply use the Reset command `:r` to unload any modules which may be compiled in memory.

## Using Grunt Project Templates

NPM, Grunt, and Bower can be customized in a great many ways, to support a variety of interesting build processes. However, for simple projects, the steps can be automated by using a Grunt project template.

The `grunt-init` tool provides a way to bootstrap a simple project from a template. The `grunt-init-purescript` project provides a simple template for a PureScript project, including a simple test suite.

To set up a project using `grunt-init`, first install the command line tool using NPM:

```
$ npm install -g grunt-init
```

Now, clone the PureScript template into your home directory. For example, on Linux, or Mac:

```
$ mkdir ~/.grunt-init
$ git clone https://github.com/purescript-contrib/grunt-init-purescript.git \
    ~/.grunt-init/purescript
```

Now, you can create a simple project in a new directory:

```
$ mkdir new-project
$ cd new-project/
$ grunt-init purescript
```

You will be asked a number of simple questions, after which the project will be initialized in the current directory, and ready to build, using the commands we have already seen:

```
$ npm install
$ bower update
$ grunt
```

The final command will build the source files, and run the test suite.

You can use this project template as the basis of a more complicated project.

## Conclusion 

_TODO_
