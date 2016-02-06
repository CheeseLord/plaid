module setup_cleanup;

import std.stdio;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import derelict.util.exception;
import yaml;

import geometry;
import globals;
import graphics;
import platform_functions;
import yaml_parser;
import load_level;

// Initialize everything.
// Returns:
//      1 -- success
//      0 -- failure
//     -1 -- complete failure; abort without cleanup
// TODO [#3]: Magic(?) numbers bad.
// TODO [#30]: This is a hacky way to do this, and probably isn't quite right.
int setup()
{
    debug writefln("Setting up.");

    if (!setupLibraries()) {
        return -1;
    }

    initializeMagicNumbers();

    bool success = setupObjects()   &&
                   setupGraphics();

    return success ? 1 : 0;
}

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Cleaning up.");

    return cleanupObjects()   &&
           cleanupGraphics()  &&
           cleanupLibraries();
}

void initializeMagicNumbers()
{
    parseMagic();
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

