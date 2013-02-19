
Use files
=========

Intro
-----

Use files specify the C and ooc dependencies of a library, along
with some basic info like its name, description.

They are useful for package managers (see [sam](https://github.com/nddrylliog/sam)),
but also for the rock compile, to import required ooc libraries, and
to know which flags and libraries to pass to the C compiler.

A few well-written .use files make using libraries very easy,
without having to worry about writing a Makefile of some sort, and
it makes compiling programs on various platforms a no-brainer.

.use files are generally located at the root of an ooc app or library.

For a language binding, the tree structure is usually:

~~~
ooc-gtk
  README.md
  gtk.use
  source
    gtk
  samples
~~~

For a pure ooc library or application, the tree structure is usually:

~~~
deadlogger
  README.md
  deadlogger.use
  source
    deadlogger
  samples
~~~

Libs search path
----------------

Using a third-party ooc library is as easy as doing `use library` in an .ooc file

When doing so, the ooc compiler will look for a `library.use` file in your lib folders.

The `$OOC_LIBS` environment variable defines the lib folders, separated by `:` on \*nix,
and ';' on Windows.

A simple setup is to have all your ooc libraries sitting in the same folder, for example
`$HOME/Dev/`, with the following structure:

~~~
someproject
  someproject.use
ooc-gtk
  gtk.use
rock
  rock.use
  sdk.use
  math.use
  pcre.use
~~~

Note that the standard ooc sdk is a library like any other - it has a .use file with
standard directives as defined below.

Syntax
------

The file is composed of key-value pairs, formatted like this:

~~~
Key1: Value1
Key2: Value2
~~~

Whitespace around the colon `:` doesn't matter. For keys that accept multiple
directives like `Libs` or `IncludePaths`, values should be separated by commas
(and whitespace is accepted).

For example, this is wrong:

~~~
Libs: -lGLU -lGL
~~~

And this is right:

~~~
Libs: -lGLU, -lGL
~~~

Versioning
----------

A use file might be versioned using version blocks, however, only some directives
are valid in a version block.

Here's an example:

~~~
Name: SDL 2.0 OpenGL support

version (linux) {
  Libs: -lGL
}

version (apple) {
  Frameworks: Carbon, OpenGL
}
~~~

Version blocks have the same syntax as in .ooc files. For more details, see the
version chapter.

Top-level directives
--------------------

Those directives cannot be versioned and must appear at the top level of
a use file.

~~~
# Short description
Name: llama

# Longer description
Description: A lib to deal with llamas

# The version of the library
Version: 0.1.3

# Modules that are automatically imported when 'use'-ing this library
Imports: llama/beast, llama/human

# For programs, the main ooc file to compile when rock is called without arguments
Main: llama/program

# This will be added to the list of folders the ooc compiler looks for .ooc files
SourcePath: source

# Dependencies - the 'use' of .use files
Requires: spit
~~~

Basic directives
----------------

~~~
# gcc's -I
IncludePaths: /some/weird/place/include

# will be included in all files using this .use file
Includes: someheader.h, someother.h

# gcc's -L
LibPaths: /some/weird/place/include

# will be linked with the final executable
Libs: -lsomething, -lotherthing

# additional .c files to compile and link into the library/executable
Additionals: source/somefile.c
~~~

pkg-config packages
-------------------

For many packages, there is already a pkg-config `.pc` file with the information
needed to make it compile right. What's more, that file is often customized depending
on what system you install the library on, which makes version blocks unnecessary.

Whenever a package has a pkg-config file, it is imperative to use `Pkgs` instead
of specifying manually `IncludePaths`, `Includes`, `LibPaths`, and `Libs`.

For example, the `cairo.use` file would probably contain:

~~~
Pkgs: cairo
~~~

pkg-config-like utilities
-------------------------

Sometimes, libraries ship with pkg-config-like utilities. `imlib2-config`,
`sdl2-config`, `llvm-config`. Those are often used similarly as pkg-config,
except without specifying a package.

When this is the case, a simple form of `CustomPkg` does the trick:

~~~
CustomPkg: sdl2-config
~~~

However, others have more complex options. For those, the full power of
`CustomPkg` is required, with 4 arguments:

  * The name of the utility to run
  * A list of arguments space-separated, always passed to the utility
  * Equivalent to pkg-config `--cflags` option
  * Equivalent to pkg-config `--libs` option

For llvm-config, this boils down to:

~~~
CustomPkg: llvm-config, core executionengine jit, --cflags, --libs --ldflags
~~~

Custom linkers
--------------

Some C++ libraries will required a C++ linker in order to work. LLVM does.

Hence, the `Linker` directive:

~~~
Linker: g++
~~~

Otherwise, the ooc compiler uses the same linker as your specified C compiler.

OSX-specific directives
-----------------------

OSX has some libraries packaged in `frameworks` instead of unix-y libs. For example,
on OSX, `-lGL` doesn't exist. For those cases, the `Frameworks` directive can be used:

~~~
Frameworks: Carbon, OpenGL
~~~

This directive has no effect on other platforms, even outside version blocks.

Android-specific directives
---------------------------

The android build process has some intricacies, which is why .use files can contain
android-specific directives:

~~~
AndroidLibs: SDL2
AndroidIncludes: ../SDL/
~~~

These really depend on the setup of your android project but it makes sense.

`AndroidLibs` are mk dependencies that need to be built, and `AndroidIncludes` are
include paths, relative to the subfolder of your app/library.

These directives have no effect on other platforms, even outside version blocks.

