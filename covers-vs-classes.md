When to use covers and classes
==============================

Intro
-----

Whenever possible, use classes.

If you're new to ooc, don't use covers because you've heard they
are "faster". Covers are powerful. Great power comes with great responsibility.
The sword cut both ways

By-reference, by-value
----------------------

### Classes ###

Classes are by-references. Which means every object is a reference. Doing that:

    Number: class {
        value: Int
        init: func (=value) {}
    }

    modifyRef: func (n: Number) {
        n = Number new(-1)
    }

    modifyInside: func (n: Number) {
        n value = -1
    }

    answer := Number new(42)
    modify(answer) // does nothing
    modifyInside(answer)

What happens in 'modifyRef' is that we change what 'n' refers to in the
modifyRef function. It doesn't modify what 'n' referred to in the first place,
in this case the 'answer' variable we gave it as argument. So 'modifyRef' has
no effect at all on 'answer'.

However, in 'modifyInside', we modify the content of what 'n' refers to.
Since 'n' refers to 'answer', the content of 'value' is modified, ie its value
is changed to -1

### Covers ###

Covers are trickier. There are two types of covers: primitive covers, and compound covers

Primitive covers allow to add methods to an existing type. For implementations
of ooc on top of C, it means you can do stuff like:

    Int: cover from int

And it's actually the way all C types are used from ooc.

As a consequence, covers are by-value. Which means that

    modify: func (i: Int) {
        i = -1
    }

    answer := 42
    modify(answer)

Doesn't modify answer.

But compound covers (you can think of them as structs) are also by value,
which means that:

    Number: cover {
        value: Int
    }

    modifyInside: func (n: Number) {
        n value = -1
    }

    answer: Number
    answer value = 42

    modifyInside(answer)

Won't modify 'answer' at all, but a *copy* of it that has been
passed to 'modifyInside'.

As an interesting side effect, a 'clone' method is futile for covers.

It also means that this won't work:

    Number: cover {
        value: Int
        init: func (=value) {}
    }

Because init will be working on a *copy* of the object, thus leaving
the original object unmodified. That's why func@ exists, ie.:

    Number: cover {
        value: Int
        init: func@ (=value) {}
    }

Where 'this' will be passed by reference. Same goes for any cover method
that modifies its content.

Heap allocation, stack allocation
---------------------------------

When you do

    NumberClass: class {}
    n := NumberClass new()

n may be allocated on the heap or on the stack, however the compiler sees fit.

However, with:

    NumberCover: cover {}
    n: NumberCover

n is allocated on the stack.


Choosing whether to allocate an object on the stack or on the heap is a
non-trivial decision. In C++ for example, it is the role of the programmer
to decide whether to allocate on the stack or on the heap.

In ooc, it's the role of the compiler. Until the language is properly
standardized and annotations are added for extern functions to allow
escape analysis, the compiler may choose to only allocate on the heap.

Allocating on the stack is much faster (since it only involves moving
the stack pointer), and the stack is always hot, the memory you get when
allocating is much more likely to be in cache than any far heap allocated
memory.

So why don't we always allocate on the stack? Why do we even bother about
heap allocation, which involves all kinds of housekeeping to know which
memory blocks are reserved and which are free?

### Why stack allocation isn't a silver bullet ###

A typical stack size for C programs on desktop OSes is between 1MB and 2MB.
Therefore, if you need to allocate big objects, you may run out of stack space.

Running out of stack space is really something to be avoided. It's a lot
harder to debug than heap allocation failures. When heap allocation fails,
you usually get back a null pointer, and tools (GDB, Valgrind) help figuring
out the cause.

However, when you run out of stack space, the program usually crashes violently
with very little information about the situation that lead to the crash.
Even worse, it could corrupt data without crashing.

What's more, often, when a program crashes because of a stack allocation failure,
the call stack is overwritten with random data, making it impossible to trace back
the origin of the problem.

To add insult to injury, as far as I know, there is no reliable and portable way
to know how much free memory is left on the stack.

For all those reasons, stack allocation is sometimes entirely avoided,
because it's tricky to deal with manually.

The following IBM DeveloperWorks article goes more in-depth into the issue:
<http://www.ibm.com/developerworks/java/library/j-jtp09275.html>

### Stack and scope ###

But wait, there's more! (assuming you're still reading at that point)

Stack-allocated variables are deallocated when they go out of scope.

What does that mean? It means that this code is wrong.

    getAnswer: func -> Int* {
        // answer is allocated on the stack
        answer := 42
        // we're returning the address of a local variable
        // this is WRONG, don't do it.
        answer&
        // when the function returns, 'answer' goes out of scope
        // and is deallocated
    }

    answerPtr := getAnswer()
    "answer = %d" printfln(answerPtr@)

Whereas this one will work perfectly:

    getAnswer: func -> Int* {
        // answer is allocated on the heap
        answer := gc_malloc(Int size)
        answer@ = 42
        // we're returning the address of a heap-allocated variable
        // no problem with that. the memory will be freed on a garbage
        // collector sweep phase, when it will have detected that
        // it's unused
        answer
    }

    answerPtr := getAnswer()
    "answer = %d" printfln(answerPtr@)

However, the first version (returning the address of a local variable)
might work sometimes: don't be surprised. If the memory address (on the stack
or in a register) where the local variable was stored isn't overwritten
between the return from the function and the time when it's used, it might
still contain the original value. But, again - it's wrong and unreliable.

### When to use stack allocation ###

For small objects for which you need by-value behavior and of which you use
gazillions in your application.

Each project is a unique situation - as a rule, I'd always advise to begin
with a class, and turn it into a cover later if the situation requires it.

However, keep in mind that allocation is often not the first place to look
if you want to optimize your application. Remember to always use a profiler
(I find that valgrind + KCachegrind work particularly well with ooc code)
to figure out where the hotspots are in your code.

