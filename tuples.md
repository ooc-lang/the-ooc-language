Tuples
======

Intro
-----

This section is rather long, and begins with an explanation of the practical
problem multi-return is supposed to solve.

If you're just looking for reference material, you may jump directly
to the 'Multi-return using Tuples' section.

Also, don't miss the last section on multi-variable declaration and assignment.


The problem
-----------

How do we make a function that return several values?

### Using an array - minmax ###

You can use an array:

    // counter-example: don't do that
    minmax: func (list: List<Int>) -> Int[] {
        min := INT_MAX
        max := INT_MIN
        for(i in list) {
            if(i < min) min = i
            if(i > max) max = i
        }

        [min, max]
    }

But it's not practical, ie. if you want to retrieve min and max, you have to do:

    // counter-example: don't do that
    result := minmax(mylist)
    min := result[0]
    max := result[1]

We're using three lines only to retrieve results from a function.

And what if minmax is changed to return only one value? The code will still
compile but fail on result[1].

### Using a list of cells (ie. a Bag) ###

Using an array doesn't allow different types, so

Let's try using a list of cells:

    // counter-example: don't do that
    meanAndTotal: func (units: List<Unit>) -> List<Cell> {
        total := 0
        for(unit in units) total += unit weight
        mean := total / units size() as Float

        [Cell new(total), Cell new(mean)] as ArrayList<Cell>
    }

And to retrieve the values:

    // counter-example: don't do that
    result := meanAndTotal(units)
    total  := result[0] get(Int)
    mean   := result[1] get(Float)

Again, three lines, looks even uglier, no guarantees, not type-safe at
compile-time. Don't do that.

### Using references ###

And here's the closest we'll come to a tolerable solution without using
tuples: out-parameters. Let's rewrite the minmax example with it

    // counter-example: don't do that
    minmax: func (list: List<Int>, min, max: Int@) {
        min = INT_MAX
        max = INT_MIN
        for(i in list) {
            if(i < min) min = i
            if(i > max) max = i
        }
    }

And to retrieve the values:

    // counter-example: don't do that
    min, max: Int
    minmax(mylist, min&, max&)

Two lines is better, but what if we do:

    minmax(mylist, null, null)

That's valid ooc, won't be caught at compile-time, but will sure as hell crash.
So it's not the perfect solution we're looking for.

Multi-return using tuples - the solution
----------------------------------------

### Multiple return types ###

Tuples can be used to return multiple values from a function. Let's
rewrite our minmax function using that.

    minmax: func (list: List<Int>) -> (Int, Int) {
        min := INT_MAX
        max := INT_MIN
        for(i in list) {
            if(i < min) min = i
            if(i > max) max = i
        }

        (min, max)
    }


### Retrieving all values - multi-variable declaration ###

We can retrieve all values by using a decl-assign with a tuple
on the left and a function call on the right

    (min, max) := minmax(mylist)

The tuple and the return type of the function call must match exactly,
any mismatch will result in a compile error.

The tuple should only contain variable accesses - any other expression
will result in a compile error.

The type of the variables declared inside the tuples are inferred
from the return type of the called function, just like regular decl-assign.

There are ways to ignore some values, that are described in other sections.


### Ignoring all but the first value ###

In the minmax example above, we can retrieve only min if we want:

    min := minmax(mylist)

It can even be used as an expression:

    "Minimum is %d" printfln(minmax(mylist))

Which leads to this rule: **when a function returning multiple values
is used as if it returned only one, the first value is used.**


### Ignoring specific values - the '_' wildcard ###

What if we want only max? We can use '_' in place of a name, in a
multi-variable declaration:

    (_, max) := minmax(mylist)

However, there is no way to use it as an expression, it has to be
unwrapped first, with a multi-variable declaration.

For that reason, **it's good design to declare return values from most
interesting to least interesting**.

### The importance of return values order ###

Take for example Process getOutput() in the sdk:

    getOutput: func -> (String, Int) {}

The first returned value is what the process wrote to stdout, and
the second value is the exit code of the process.

The function used to be declared like that

    getOutput: func -> String {}

And didn't allow to get the exit code. Adding functionality didn't
hurt compatibility at all though - no code broke, because of careful
design.

Be careful when designing APIs. Plan for growth. Listen to Guy Steele
(and his 'Growing a Language' talk)

### The '_' wildcard in greedy mode ###

We said above that the tuple and the return type of the function call
on either side of a multi-variable decl-assign should match exactly.

For example, given this:

    plainWhite: func -> (Int, Int, Int, Int) { (1, 2, 3, 4) }

The following lines are invalid:

    (one, two) := plainWhite()
    (_, two) := plainWhite()

Why? So that when incompatible changes are made to an API, you're
aware of it at compile-time, not at run-time.

However, both these lines are valid:

    one := plainWhite() // as we've seen before
    (_, two, _) := plainWhite()

Although plainWhite() returns 4 values, a tuple with only 3 elements
works.

**A '_' used at the end of a tuple will ignore every remaining return value**

So that

    one := plainWhite()

Is actually equivalent to:

    (one, _) := plainWhite()


Tuples beyond return - multi-declaration and multi-assign
---------------------------------------------------------

Using tuples on both sides of the decl-assign operator (:=) or
the assign operator (=) is valid.

Examples:

    (x, y, z) := (1, 2, 3)

    (a, b) = (b, a)

Swapping variables is valid, and should be supported by compliant
ooc compilers/runtimes.


















