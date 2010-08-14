Properties
==========

Intro
-----

Properties are a handy way to get rid of getters and setters while retaining
their advantages.

The justification for getters and setters, beyond relieving feelings of guilt
for not being able to correctly apply object-oriented principles such as
encapsulation, is to allow for computation to happen when a value is retrieved
and/or set (besides the actual memory read/write).

However, this results in long-winded and hard-on-the-eyes code such as this:

    setX(getX() + 1)
    setY(getY() + 2)
    setZ(getZ() + 3)

When one come simply write, with regular variables

    (x, y, z) += (1, 2, 3)

Which is much easier on the eyes.
(Read on 'tuples' for more information about multi-declaration / multi-assignment)

A dumb property
---------------

Turning a regular variable declaration into a property is as simple
as adding a pair of brackets {} after it.

    Tree: class {
        age: Int {}
    }

At this point, 'age' behaves exactly as a variable, except that instead
of direct memory read/write, it's now modified via automatically-generated
getters and setters.

The above code is also equivalent to:

    Tree: class {
        age: Int { get set }
    }

Or, if you prefer:

    Tree: class {
        age: Int {
            get
            set
        }
    }

Hooking on get and set
----------------------

There's more to it. get and set can have a body, much like methods, except
without specifying argument types or return types.

    Tree: class {
        age: Int {
            get
            set (newAge) {
                if(newAge > 0) age = newAge
            }
        }
    }

In this example, validation is done within the property setter.
It could be used to validate state transitions for a finite state machine,
for example.

Virtual properties
------------------

In the previous sections, we thought of properties as 'variable declarations
on steroids'. This is not exactly true. A property can exist without any
variable of the same name existing.

For our tree class, we might define an 'old' property that is computed from
its 'age' property.

    old: Bool {
        get {
            age > 100
        }
    }

NOTE: using undocumented 'magic numbers' in code is bad practice: don't do it.
Use constants with meaningful names instead - or better yet, make it configurable.

Here, there is no real variable named 'old' that can be modified. Only a read-only
property that is computed on-demand. Note that virtual properties can have setters
too.

Which leads us to the following definition: virtual properties are properties
with custom getters and setters that don't reference the name of the property.

In our case, when we define get, we don't access 'old', which makes it a virtual
property.

Foreign function interfacing
----------------------------

Properties setters and getters can be extern functions (ie. functions defined
outside ooc code). Let's take an example for a well-known GTK widget:

    use gtk
    import gtk/[Gtk, Widget]

    Label: cover from GtkLabel* extends Widget {
        new: extern(gtk_label_new) static func (text: GChar*) -> This

        text: GChar* {
            set: extern(gtk_label_set_text)
            get: extern(gtk_label_set_text)
        }
    }

Once again, properties make code more readable and more straight-forward
to write.









