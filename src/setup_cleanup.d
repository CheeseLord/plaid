module setup_cleanup;

private import std.stdio;

private import derelict.sdl2.image;
private import derelict.sdl2.sdl;
private import derelict.util.exception;
private import yaml;

private import geometry;
private import globals;
private import graphics;
private import observer;
private import platform_functions;
private import yaml_parser;
private import load_level;
private import win_lose;

private enum InitIndex: int {
    NOTHING_INITIALIZED = 0,
    LIBRARIES,
    MAGIC_NUMBERS,
    OBSERVERS,
    OBJECTS,
    GRAPHICS,
}

private InitIndex setupProgress;

// Initialize everything. Return true on success, false otherwise.
bool setup()
{
    debug writefln("Setting up.");

    setupProgress = InitIndex.NOTHING_INITIALIZED;

    // Note: the order of initialization here must match the enum InitIndex,
    // defined above.
    // Note: we need to use ++setupProgress instead of setupProgress++ so that
    // the first one (which increments from 0 to 1) returns a nonzero value.
    if     ((setupLibraries()         && ++setupProgress) &&
            (initializeMagicNumbers() && ++setupProgress) &&
            (initializeObservers()    && ++setupProgress) &&
            (setupObjects()           && ++setupProgress) &&
            (setupGraphics()          && ++setupProgress)) {
        return true;
    }
    else {
        cleanup();
        return false;
    }
}

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Cleaning up.");

    switch (setupProgress) {
        case InitIndex.GRAPHICS:
            if (!cleanupGraphics()) {
                return false;
            }
            goto case;
        case InitIndex.OBJECTS:
            if (!cleanupObjects()) {
                return false;
            }
            goto case;
        case InitIndex.OBSERVERS:
            // No cleanupObservers() function.
            goto case;
        case InitIndex.MAGIC_NUMBERS:
            // No cleanupMagicNumbers() function.
            goto case;
        case InitIndex.LIBRARIES:
            if (!cleanupLibraries()) {
                return false;
            }
            goto case;
        case InitIndex.NOTHING_INITIALIZED:
            return true;
        default:
            assert(false);
    }
}

bool initializeMagicNumbers()
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


bool initializeObservers()
{
    observers = new ObserverList();

    win_lose.registerObservers();

    return true;
}

