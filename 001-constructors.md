
Constructors
============

Intro
-----

In ooc, unlike Java/Scala/C++/C#, 'new' isn't a keyword, but a static method.

For example:

~~~
    dog := Dog new("Pif")
~~~

However it's uncommon to directly define a new method. Instead, an init method is
defined, like this:

~~~
    Dog: class {

        name: String

        init: func (=name) {}

    }
~~~

When an 'init' method is defined, a corresponding 'new' static method is defined, in our case,
the code above is equivalent to:

~~~
    Dog: class {

        name: String

        init: func (name: String) {
            this name = name
        }

        new: static func (name: String) -> This {
            this := This alloc() as This
            this init()
            this
        }

    }
~~~

'alloc' is a method of Class, which can be defined like this, for example:

~~~
    /// Create a new instance of the object of type defined by this class
    alloc: final func ~_class -> Object {
        object := gc_malloc(instanceSize) as Object
        if(object) {
            object class = this
        }
        return object
    }
~~~

In ooc implementations, Object and Class are often classes defined in .ooc source
files, so you can easily study their source code. You can typically find their definitions
in sdk/lang/ (because everything in the lang/ package is automatically imported)

Reminder: member-arguments and assign-arguments
-----------------------------------------------

This:

~~~
    DiceRoll: class {
        value: Int

        init: func (=value) {}
    }
~~~

is the equivalent of this:

~~~
    DiceRoll: class {
        value: Int

        init: func (.value) {
            this value = value
        }
    }
~~~

which is the equivalent of this:

~~~
    DiceRoll: class {
        value: Int

        init: func (value: Int) {
            this value = value
        }
    }
~~~

Ie '.' allows 'value's type to be inferred from the member variable
of the same name, and '=' does the same plus assigns it in the constructor.

This works for any method, not only for constructors. However, if you're using
it for setters, you probably want to use properties instead.

Multiple constructors
---------------------

As any method, constructors can be overloaded with suffixes.

Suffixes may seem annoying at first, seen as a sort of 'manual name mangling',
but aside from helping to debug, they're also a way to document the purpose of your
different constructors. For that reason, it's always a good idea to give meaningful
suffixes that lets one hint the reason for existence of a constructor.

From a constructor, you can call another constructor with init(), just like a regular
method.

You can also call a super-constructor with super()

~~~
    Dog: class {

        name: String

        init: func ~defaultName {
            init("The Man")
        }

        init: func (=name) {}

    }
~~~

Inheritance
-----------

A common mistake is to think that constructor are inherited, because they are standard
methods. However, this behavior would be harmful, as explained in the following example:

~~~
    Logger: class {
        prefix: String

        init: func (=prefix) {}

        log: func (msg: String) {
            "%s%s" printfln(prefix, msg)
        }
    }

    FileLogger: class extends Logger {
        output: FileWriter

        init: func ~withPath (path: String) {
            super(prefix)
            output = FileWriter new(path)
        }

        log: func (msg: String) {
            output write(prefix). write(msg). write('\n')
        }
    }
~~~

What would happen if the first constructor defined in Logger was available
for FileLogger? Let's find out

~~~
    warn := FileLogger new("WARN")
    warn log("Somebody set us up the stacktrace")
~~~

The constructor call, if it was valid, would either return a Logger, which is
not what we want, or by some miracle trick, return a FileLogger - but one
that wouldn't be properly initialized, so that log() would crash.

Super func (and beyond)
-----------------------

However, there are times when one truly wants to relay a constructor
in an inherited class, such as:

~~~
    Expression: abstract class {
        eval: abstract func -> Int
    }

    BinaryOp: abstract class extends Expression {
        left, right: Expression

        init: func ~lr (=left, =right) {}
    }

    Add: class extends BinaryOp {
        init: func ~lr (=left, =right) {}
    }
~~~

Repeating the 'init~lr' definition in Add violates the Don't Repeat Yourself (DRI)
principle. Besides, if functionality is added to the base BinaryOp init~lr, it
wouldn't be replicated in Add init~lr.

For this precise case, the 'super func' construct exists:

~~~
    Add: class extends BinaryOp {
        init: super func ~lr
    }
~~~

This behaves exactly as if we had written:

~~~
    Add: class extends BinaryOp {
        init: func ~lr (.left, .right) {
            super(left, right)
        }
    }
~~~
