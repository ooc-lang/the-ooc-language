Generics
========

Intro
-----

Generics are one of the most commonly misunderstood features of ooc.

Many people attempt confuse them with templates (like in C++ or D) and are
surprised when things like this don't work:

    Vector2: class <T> {
        x, y: T
	init: func(=x, =y) {}
        add: func (r: This<T>) {
            new(x + r x, y + r y)
        }
    }

(Don't worry about the syntax for now, I'll get to it later)

Why doesn't this work? It's because you can't do much with generic variables.
The whole point is that *we don't know which type they are* until we run the
program.

One might instanciate a Vector2<Int> - in which case the + operator
makes sense - but they could also instanciate a Vector2<Carrot>, where Carrot
wouldn't necessarily have a + operator.

Besides, since ooc is statically typed, we wouldn't know which + operator
to use - they're not all the same! We don't add two ints the same manner that
we add two floats, and so on.

Generic functions and type parameters
-------------------------------------

So, if we can't use any operator on generic variables - nor can we call
methods on them, then what are they good for? Sure looks useless from here.

Well, here's one thing we can do, for example:

    identity: func <T> (val: T) -> T {
        val
    }

Woha. What just happened here? Let's recap line by line.

    identity: func <T> (val: T) -> T

Here, we declare a function named 'identity', with one type parameter named T,
taking one parameter named 'val', and returning a value of type T.

Type parameters are the names listed between the angular brackets < and >. You
can have as many as you want (although if you have more than few of them,
you're probably doing it wrong)

When you declare a type parameter, it tells the compiler about a new type,
that we know nothing about at compile-time. Well, not nothing. Remember
classes? Here's how we access the class of an object:

    object class

And if object was of type Carrot, that amounts exactly to doing just:

    Carrot

What is that, exactly? It's an access to a class. What is a class? An instance
of Class, which is declared in lang/CoreTypes.ooc If you actually go on and open
CoreTypes, here is a simplified version of what you will find:

    Class: class {
    	name: String
	size, instanceSize: SizeT
    }

(Reminder: SizeT can be used to store the size of something. On 32-bits
platforms, it's 32-bits wide. On 64-bits platforms, it's 64-bits wide, and so
on. Basically, it's an integer type that is as wide as a Pointer)

So back to our generic stuff. I said we knew nothing about generic types. And
in fact, it was a downright lie. Please accept my apologies. The reality is -
we know all that matters! If you try to execute the following piece of code:

    test: func <T> (t: T) { T class name println() }
    test(42)

You'll find out something very strange and puzzling.. it prints "Class" !

We just discovered that we can access type parameters just like any other
variable. And since T is a class, and we can access various fields of a class,
here's what we can do:

    test2: func <T> (t: T) {
    	"name = %s, size = %zd, instanceSize = %zd" printfln(
	T name, T size, T instanceSize)
    }
    test2(42)

This will likely print something like "name = Int, size = 4, instanceSize =
4".

Then you must wonder why is there 'size' and 'instanceSize', if they're equal?
Well, they're not equal in all cases. Most importantly, for objects (which are
references, remember), 'object class size' is equal to 'Pointer size', but
'object class instanceSize' is equal to the actual number of bytes we should
allocate when we create an object of this class.

But I digress. (Then again, you're the curious one - not me.)

So let's analyze the second line of our 'identity' function above:

    val

Let's see. It's the last line of a non-void function, so it means it's
returned. 'val' refers to a variable declaration which happens to be a
function argument, of a generic type. (*phew* - at this point, repeat that
last line to yourself two or three times to impreign it into your brain)

So basically what our function does is... just pass through what we give it as
an argument! Let's try that

    42 toString() println() // just to be sure
    identity(42) toString() println() // still a little trivial
    identity(identity(identity(identity(42)))) toString() println() // whoa.

Yup, it prints 42 alright.

But wait! I just said above that the compiler *couldn't do anything useful
with a generic variable*, that is, either use an operator on it or call a
function on it, because it doesn't know its type. And in our example, we
clearly see that the 'identity' function has return type T, which is a generic
type! (Because it's between the < and >, remember?)

Have I lied again? Let's find out.

Generic type inference
----------------------

Let's do a little experiment:

    a := 42
    b := identity(42)
    "%s and %s" printfln(a class name, b class name)

What did you get? Int and Int, right? But - but the return type of 'identity'
is T! Shouldn't b's type be T too?

Well, no.

And thank God for that.

In fact, if it was so, generics would be pretty much useless (heh, they're limited enough already!)

So what kind of magic is going on? White magic. Which really isn't magic at
all.

You see, when you call:

    identity(42)

And the definition of identity is

    identity: func <T> (val: T) -> T

Here's what the compiler figures out: well, we have one unknown type (that
is, generic type), called 'T'. Also, the first (and only) argument is of that
type. Hey - let's infer what 'T' is from the type of this argument!

And that's exactly what it does. As a result, it figures the type of b to be
Int - since we can know all that at compile-time. It makes b easier to use,
avoid tons of cast, and is good for your karma.

Here's another example.

    printTypeName: func <T> (T: Class) { T name println() }
    printTypeName(Object)

Then it prints "Object". Did we find a way to print strings without having to
enclose them between quotes? Hopefully not. That would be messy, man. Talk
about Perl :/

However, we have just discovered that we can pass types as arguments to
functions. Of course, because types are just instances of 'Class', right? So
they're objects. So they're values. So we can pass them around.

So here, the compiler figures that, well - we give it the solution to 'what is
T'. It is then not too big a challenge for the compiler to go from here.

Then again, we could have done:

    dumbPrintTypeName: func (T: Class) { T name println() }
    dumbPrintTypeName(Object)

Since we don't use T as a type anywhere. So why even bother with this <T>
thing, hmm? Why does the compiler even allow it? Read on if you want to find out.

Generic return types
--------------------

Here's a little riddle for you. How does the compiler figure out the real return
type of this function:

    sackOfUnknown: func <T> -> T { 42 }
    sackOfUnknown()

Anyone? Ah, I see a hand in the back. What do you say? The type of the return
expression? WRONG. But that was an honest try. One point for effort.

So what's the solution? "It doesn't." That's right. The compiler doesn't even
bother. We give absolutely no clue as to the type of T when we're calling it -
and the compiler never tries to infer a generic type from the return
expression (that's useless, I mean - why even make a generic function in the
first place? Too lazy to type out 'Int'? Yeah. Call me back when you have ABI
incompatibilities because you changed a return expression. Or rather - don't.)

So how do we make a function that

  - has a generic return type, let's say 'T'
  - doesn't take an argument of type T ?

Well, that's precisely where that useless thing presented in the previous
section comes in very handy:

   theAnswer: func <T> (T: Class) -> T {
   	match T {
	    case Int    => 42
	    case Float  => 42.0
	    case String => "forty-two"
	    case        => Exception new("You're not worthy.") throw(); 0
	}
   }
   rational := theAnswer(Int)
   real     := theAnswer(Float)
   text     := theAnswer(String)
   theAnswer(Object) // ka-boom!

What just happened? We used a match on 'T', which means we're comparing it.
We're comparing it with the types 'Int', 'Float', 'String', trying to return
expressions. And if it's none of these types, it just blows up.

Note: in that case, our theAnswer function is pretty useless

Generic classes
---------------

Now that's all good and fancy - but generic functions aren't actually that
useful. If we can't use operators nor functions on generic types, what can we
do? Well - store them! That's the way all collections work.

Let's start with a simple one:

    Slot: class <T> {
        element: T
	init: func (.element) { set(element) }
	set: func (=element) {}
	get: func -> T { element }
    }

    s := Slot new(3.14)
    s get() toString() println()
    s T name println()

Not that bad, eh? (It should print 3.14 and Float - or some other type, if
you're in the future and ooc has a proper number tower)

But wait - get is defined like that:

    get: func -> T { element }

And clearly T is a generic type, ie. it could be anything at runtime, and
*yet* the compiler figures it out right.

So what happens here? Let's look at the call, since it's the info from which
the compiler works to infer generic types:

    s get()

Hmmph. Not many types there - except maybe.. the type of s. Which is what
exactly?

    s := Slot new(3.14)

Well it turns out that Slot new is just a regular method call, the generic
type T is inferred to 'Float', and so 's' becomes a Slot<Float>

Hence, the compiler sees the get() call as:

    Slot<Float> get()

And it sees the get definition as

    Sloat<T> get: func {}

From here, inferring that T = Float is trivial.

Advanced type inference
-----------------------

One of the most advanced example of type inference in the whole SDK
is probably the List map() function. Here is its signature (ie.
definition without the body) :

    map: func <K> (f: Func (T) -> K) -> This<K>

So basically it turns a List<T> into a List<K>, by calling f to turn
every T into a K. Makes sense.

The question is now - how does the compiler infer K? The only info we have
about it, is that it's the return type of function we pass as an argument
to the function.

Well - no big deal then, if we do:

    intToString: func (i: Int) -> String { i toString() }
    strings := numbers map(intToString)

Then we know that K = String from the definition of intToString.

But wait, there's a nice infers-everything syntax for closures, ie.:

    stringsToo := numbers map(|x| x toString())

And here, we're doomed. The closure insides attempts to infers its whole
signature (argument types, return type, etc.) from the type of the
corresponding argmuent in the map definition. But map doesn't provide
a definitive answer, since the return type is generic.

Hence, the compiler falls back to the only possible resolution of this
madness: it infers K from the return expression inside the closure.

This case is the *only case* where rock considers the return expression
inside functions to infer any type at all.

Under the hood
--------------

How does it work under the hood?

Here is the naive implementation: generic type arguments as passed
as function arguments, ie a call to:

    ArrayList<Int> new()
    identity(42)

becomes (without mangling):

    ArrayList_new(Int_class());
    identity()


Type arguments in classes become variables:

    ArrayList: class <T> {}

is

    ArrayList: class {
        T: Class
    }

Class type arguments are assigned in the constructor to the appropriate
values.




