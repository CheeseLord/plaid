module setup_cleanup;

private import std.stdio;
private import std.string: format;

private import derelict.sdl2.image;
private import derelict.sdl2.sdl;
private import derelict.util.exception;
private import yaml;

private import geometry;
private import globals;
private import graphics;
private import load_level;
private import observer;
private import sound;
private import sound_effects;
private import win_lose;
private import yaml_parser;

private enum InitIndex: int {
    NOTHING_INITIALIZED = 0,
    LIBRARIES,
    MAGIC_NUMBERS,
    OBJECTS,
    GRAPHICS,
    OBSERVERS,
    EVERYTHING_INITIALIZED,
}

private InitIndex setupProgress;

// Initialize everything. Return true on success, false otherwise.
bool setup()
{
    debug writefln("Setting up.");

    setupProgress = InitIndex.NOTHING_INITIALIZED;

    // Note: the order of initialization here must match the enum InitIndex,
    // defined above.
    if     ((setupLibraries() && incProgressTo(InitIndex.LIBRARIES    )) &&
            (setupMagic()     && incProgressTo(InitIndex.MAGIC_NUMBERS)) &&
            (setupObjects()   && incProgressTo(InitIndex.OBJECTS      )) &&
            (setupGraphics()  && incProgressTo(InitIndex.GRAPHICS     )) &&
            (setupObservers() && incProgressTo(InitIndex.OBSERVERS    ))) {
        // Make sure we didn't miss a stage.
        if (incProgressTo(InitIndex.EVERYTHING_INITIALIZED)) {
            return true;
        }
    }

    cleanup();
    return false;
}

// Increment setupProgress, and check that it reaches the stage we expect.
private bool incProgressTo(InitIndex newProgress)
{
    setupProgress++;
    assert (setupProgress == newProgress,
            format("Setup stages are out of order: enum says stage %s should "
                   "be %s, but we did %s instead.", cast(int)(setupProgress),
                   setupProgress, newProgress));

    debug (SetupCleanup) {
        writefln("Setup progress: %s", setupProgress);
    }

    return (setupProgress == newProgress);
}

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Cleaning up.");

    // Stores the InitIndex of the next thing to be cleaned up.
    InitIndex cleanupProgress = InitIndex.EVERYTHING_INITIALIZED;

    if (decProgressTo(cleanupProgress, InitIndex.OBSERVERS)) {
        // No cleanupObservers() function.
    }

    if (decProgressTo(cleanupProgress, InitIndex.GRAPHICS)) {
        if (!cleanupGraphics()) return false;
    }

    if (decProgressTo(cleanupProgress, InitIndex.OBJECTS)) {
        if (!cleanupObjects()) return false;
    }

    if (decProgressTo(cleanupProgress, InitIndex.MAGIC_NUMBERS)) {
        // No cleanupMagicNumbers() function.
    }

    if (decProgressTo(cleanupProgress, InitIndex.LIBRARIES)) {
        if (!cleanupLibraries()) return false;
    }

    decProgressTo(cleanupProgress, InitIndex.NOTHING_INITIALIZED);

    return true;
}

// Decrement setupProgress, and check that it was at the stage we expect.
private bool decProgressTo(ref InitIndex progress, InitIndex newProgress)
{
    progress--;
    assert (progress == newProgress,
            format("Cleanup stages are out of order: enum says stage %s "
                   "should be %s, but we did %s instead.",
                   cast(int)(progress), progress, newProgress));

    debug (SetupCleanup) {
        if (setupProgress >= progress)
            writefln("Cleanup progress: %s", progress);
        else
            writefln("Cleanup: skipping %s", progress);
    }

    return (setupProgress >= progress);
}

bool setupMagic()
{
    parseMagic();

    // TODO [#13]: If an exception is thrown, return false.
    return true;
}

// Set up everything associated with each library we use.
bool setupLibraries()
{
    bool success = true;

    success &= setupSDL();
    success &= Sound.load();

    return success;
}

// Clean up everything associated with each library we use.
bool cleanupLibraries()
{
    bool success = true;

    success &= cleanupSDL();

    return success;
}

// Set up everything associated with SDL.
bool setupSDL()
{
    // Load the SDL shared library.
    // The exception handling code here is adapted from
    //     https://github.com/DerelictOrg/DerelictUtil/wiki/DerelictUtil-for-Users:
    try {
        DerelictSDL2.load();
    }
    catch (SymbolLoadException e) {
        stderr.writefln("Error: Derelict SDL2 failed to load a symbol: %s",
                        e.msg);
        return false;
    }
    catch (SharedLibLoadException e) {
        stderr.writefln("Error: Failed to load SDL2 library: %s", e.msg);
        for (Throwable curr = e.next; curr !is null; curr = curr.next) {
            stderr.writefln("    Further info: %s", curr.msg);
        }
        return false;
    }
    catch (Exception e) {
        stderr.writefln("Error: Failed to load Derelict SDL2: %s", e.msg);
        return false;
    }

    // Load the SDL2 image library.
    try {
        DerelictSDL2Image.load();
    }
    catch (Exception e) {
        stderr.writefln("Error: Failed to load SDL2_Image: %s", e.msg);
        return false;
    }

    // Load and setup sound library.
    try {
        Sound.init();
    }
    catch (Exception e) {
        stderr.writefln("Error: Failed to load SDL2_Mixer: %s", e.msg);
        return false;
    }

    // Initialize SDL.
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Error: Failed to initialize SDL: %s\n",
               SDL_GetError());
        return false;
    }

    // Initialize images.
    // If we want to use other file formats, add them here.
    int flags = IMG_INIT_PNG;
    if ((flags & IMG_Init(flags)) != flags) {
        printf("Error: Failed to initialize SDL_Image\n");
        return false;
    }

    return true;
}

// Clean up everything associated with SDL.
bool cleanupSDL()
{
    IMG_Quit();
    // From http://wiki.libsdl.org/SDL_Quit:
    //     "You should call this function even if you have already shutdown
    //      each initialized subsystem with SDL_QuitSubSystem(). It is safe to
    //      call this function even in the case of errors in initialization."
    // Therefore, don't worry about checking if the SDL_Init succeeded.
    SDL_Quit();

    return true;
}


bool setupObservers()
{
    observers = new ObserverList();

    win_lose     .registerObservers();
    sound_effects.registerObservers();

    return true;
}

