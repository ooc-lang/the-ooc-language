First-class functions
=====================

Intro
-----

Functions are pieces of code that can take arguments, and return values.

Named functions are declared with this syntax:

~~~
    <name> : func <arguments> <return type> {
        <body>
    }
~~~

Where arguments are comma-separated, enclosed between parenthesis, and return type
is prefixed with a right arrow ->.

Arguments may be omitted if the function doesn't take any, and return type
may be omitted too, if the function is void.

Example:

~~~
    max: func (a, b: Int) -> Int {
        a > b ? a : b
    }
~~~

But this is a valid expression too:

~~~
    func <arguments> <return type> {
        <body>
    }
~~~

And with decl-assign, we can declare a variable named 'max', equal
to this expression. And then use it very much like a function

~~~
    max := func (a, b: Int) -> Int {
        a > b ? a : b
    }
    answer := max(-1, 42)
~~~

Differences between function and first-class functions
------------------------------------------------------

The first difference is: functions are immutable. First-class functions
are variables, and thus can be overwritten by simple assignment.

~~~
    // this is invalid: don't do that.
    someFunc: func {}
    someFunc = someOtherFunc

    // this, on the other hand, is valid
    someFunc := func {}
    someFunc = someOtherFunc
~~~

The second difference is: first-class functions can capture context.
Closures are first-class functions that capture context.

~~~
    // here's a normal function
    clone: func (l: List<Int>) -> List<Int> {
        copy := ArrayList<Int> new(l size())
        l each(func(element: Int) {
            copy add(element)
        })
        copy
    }
~~~

Here, our anonymous, first-class function which also happens to be a closure, is

~~~
    func(element: Int) {
        copy add(element)
    }
~~~

It captures the context because we access 'copy' in it - which isn't an
argument of the function, nor a variable declared inside the function.

It's declared outside, and still we can access it - that's what capturing
context is.

So let's sum up: first-class functions may be overwritten by assignment,
and may capture context.

The type of first-class functions
---------------------------------

So, when we do:

~~~
    max := func (a, b: Int) -> Int {
        a > b ? a : b
    }
~~~

What exactly is the type of 'max' ?

Let's declare it in two steps  instead:

~~~
    max : Func (Int, Int) -> Int
    max = func (a, b: Int) -> Int {
        a > b ? a : b
    }
~~~

`Func` is a type that has a special syntax:

~~~
    Func <argument types> <return type>
~~~

As with regular functions declaration, both argument types and return types
can be omitted.

Type inference - ACS
--------------------

Declaring the type of first-class functions is mostly useful in function arguments.

For example, in the SDK, the declaration of each goes like this:

~~~
    List: class <T> {
        each: func(f: Func (T)) {
            // ...
        }
    }
~~~

So it takes a function that takes one argument of type T

Hence, clearly doing that in our clone function above:

~~~
    l each(func(element: Int) {
        copy add(element)
    })
~~~

Is unnecessary. Since we know that l is a List<Int>, and that each takes
a Func (T) then we know that element is of type Int.

And thus, we can write that:

~~~
    l each(|element|
        copy add(elements)
    )
~~~

The proper syntax for that is

~~~
    call(|<name of arguments>|
        <body>
    )
~~~

If there are no arguments, this is valid:

~~~
    call(||
        <body>
    )
~~~

And is then equivalent to:

~~~
    call(func {
        <body>
    })
~~~

The return type is inferred as well.

Other differences - member functions vs member first-class functions
--------------------------------------------------------------------

~~~
    Dog: class {

        shout: func {
            "Woof woof" println()
        }

    }

    d := Dog new()
    d shout()

    Dog shout = func {
        "Ruff ruff" println()
    }
    d2 := Dog new()
    d shout()
    d2 shout()
~~~

Prints:

~~~
    Woof woof
    Ruff ruff
    Ruff ruff
~~~

When assigning 'Dog shout', we change the member method of *all* past and
future Dog instances. This happens because 'shout' is actually stored in the meta-class

Consider the differences with that instead:

~~~
    Dog: class {

        shout := func {
            "Woof woof" println()
        }

    }

    d := Dog new()
    d shout()

    d shout = func {
        "Ruff ruff" println()
    }
    d2 := Dog new()
    d shout()
    d2 shout()
~~~

Prints:

~~~
    Woof woof
    Ruff ruff
    Woof woof
~~~

Here, 'shout' is a member variable. Assigning to 'd shout' changes it
only for that instance, so d2 shout isn't changed.
