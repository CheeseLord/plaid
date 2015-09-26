import std.stdio;

import mylib;

import GTKTest;

void main()
{
    // FIXME [#1]: Remove this exclamation mark, once we can figure out how to
    // use a text editor.
    writefln("Hello, world!");

    writefln("One more than 5 is: %s", successor(5));
    writefln("Twice 5 is: %s", twice(5));

    // TODD [#2]: Say goodbye to the world, for symmetry.

    testWindow();
}
