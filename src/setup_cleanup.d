module setup_cleanup;

import std.stdio;

import derelict.sdl2.sdl;
import derelict.util.exception;
import yaml;

import globals;
import platform_functions;
import yaml_parser;

// Initialize everything. 
bool setup()
{
    debug writefln("Setting up.");

    initializeMagicNumbers();

    bool success = true;

    success &= setupLibraries();
    success &= setupWindow();
    success &= setupObjects();

    return success;
}

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Cleaning up.");

    bool success = true;

    success &= cleanupObjects();
    success &= cleanupWindow();
    success &= cleanupLibraries();

    return success;
}

// TODO [#3]: Magic numbers bad.
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

    // Initialize SDL.
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Error: Failed to initialize SDL: %s\n",
               SDL_GetError());
        return false;
    }

    return true;
}

// Clean up everything associated with SDL.
bool cleanupSDL()
{
    // From http://wiki.libsdl.org/SDL_Quit:
    //     "You should call this function even if you have already shutdown
    //      each initialized subsystem with SDL_QuitSubSystem(). It is safe to
    //      call this function even in the case of errors in initialization."
    // Therefore, don't worry about checking if the SDL_Init succeeded.
    SDL_Quit();

    return true;
}

// Set up the game window.
bool setupWindow()
{
    // Create a window.
    // TODO [#3]: Magic numbers bad.
    window = SDL_CreateWindow("Plaid",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        640, 480, SDL_WINDOW_OPENGL);

    if (window is null) {
        writefln("Error: Failed to create window for plaid.");
        return false;
    }

    return true;
}

// Clean up the game window.
bool cleanupWindow()
{
    if (window !is null) {
        SDL_DestroyWindow(window);
    }

    return true;
}

// Set up game objects.
bool setupObjects()
{
    // Nothing to do right now
    return true;
}

// Clean up game objects.
bool cleanupObjects()
{
    // Nothing to do right now
    return true;
}

