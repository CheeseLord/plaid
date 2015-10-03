module OpenAlTest;

private import std.stdio;

// TODO: Better fix for all the fprintfs.
private import core.stdc.stdio;
private import std.string: toStringz;

private import derelict.alure.alure;

// This code adapted from the ALURE example 'alureplay.c', included with the
// ALURE source tarball.

int testSound()
{
    scope (exit) {writefln("Test 999");}
    DerelictALURE.load();

    writefln("Test 1");

    // Apparently alureCreateBufferFromFile takes a non-const char*?
    char[] soundFile = "test.ogg".dup;

    ALuint src, buf;

    // This could probably be made about 1/3 as long using scope(exit)....

    if (!alureInitDevice(null, null))
    {
        fprintf(core.stdc.stdio.stderr, "Failed to open OpenAL device: %s\n",
                alureGetErrorString());
        return 1;
    }

    writefln("Test 2");

    alGenSources(1, &src);
    writefln("Test 2b"); // Or not 2b?
    if (alGetError() != AL_NO_ERROR)
    {
        fprintf(core.stdc.stdio.stderr, "Failed to create OpenAL source!\n");
        alureShutdownDevice();
        return 1;
    }

    writefln("Test 3");

    buf = alureCreateBufferFromFile(soundFile.ptr);
    if (!buf)
    {
        fprintf(core.stdc.stdio.stderr, "Could not load %s: %s\n",
                toStringz(soundFile), alureGetErrorString());
        alDeleteSources(1, &src);

        alureShutdownDevice();
        return 1;
    }

    writefln("Test 4");

    alSourcei(src, AL_BUFFER, buf);
    if (alurePlaySource(src, &eos_callback, null) == AL_FALSE)
    {
        fprintf(core.stdc.stdio.stderr, "Failed to start source!\n");
        alDeleteSources(1, &src);
        alDeleteBuffers(1, &buf);

        alureShutdownDevice();
        return 1;
    }

    writefln("Test 5");

    while (!isdone)
    {
        alureSleep(0.125);
        alureUpdate();
    }

    writefln("Test 6");

    alDeleteSources(1, &src);
    alDeleteBuffers(1, &buf);

    writefln("Test 7");

    alureShutdownDevice();
    return 0;
}


shared int isdone = 0;
extern (C) private void eos_callback(void *unused, ALuint unused2)
{
    isdone = 1;

    // Does DMD even care about unused parameters?
    cast(void)unused;
    cast(void)unused2;
}

