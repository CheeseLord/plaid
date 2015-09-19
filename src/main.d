import std.stdio;

import mylib;

void main()
{
    // FIXME [#1]: Remove this exclamation mark, once we can figure out how to
    // use a text editor.
    writefln("Hello, world!");

    writefln("One more than 5 is: %s", successor(5));
    writefln("Twice 5 is: %s", twice(5));
}
