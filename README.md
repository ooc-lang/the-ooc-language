# the ooc language

## status

**In progress**, send feedback to amos@ofmlabs.org and mention 'ooc' in the subject.

Thanks a lot =)

Amos Wenger aka [@nddrylliog](http://twitter.com/nddrylliog)

## how to build the doc ?

Easy,

    $ make
    
will generate a single-page, HTML version of the documentation.

Then,

    $ make publish
    
will switch to the `gh-pages` branch, commit the modifications and push the commits to `origin` (which may be your forked repository).

## todo

1. Figure out how to order the sections.
2. Merge branch ['mdoc'](https://github.com/romac/the-ooc-language/tree/mdoc) into 'master' in a way that will let us generate both versions of the documentation with a single Makefile.
3. ...
4. Profit !