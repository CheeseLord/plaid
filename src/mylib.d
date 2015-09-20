/**
 * Add one to the input.
 */
int successor(int x) pure
{
    return x + 1;
}

/**
 * Double the input.
 */
int twice(int x) pure
{
    return x + x;
}

/// This example is generated automatically from a unittest
unittest
{
    assert(twice(5) == 10);
}
