module setup_cleanup;

import std.stdio;

import derelict.sdl2.sdl;

import globals;

// Initialize everything. On success, return true. On failure, report the error
// and return false.
bool setup()
{
    // Set up SDL.
    DerelictSDL2.load();
    SDL_Init(SDL_INIT_VIDEO);

    // Create a window.
    window = SDL_CreateWindow("Plaid",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        640, 480, SDL_WINDOW_OPENGL);

    if (window is null) {
        writefln("Error: failed to create window.");
        return false;
    }

    return true;
}

// Clean up everything that was initialized. On success, return true. On
// failure, report the failure and return false. Not that there's much the
// caller can do about a failure to cleanup....
bool cleanup()
{
    writefln("Exiting.");
    SDL_DestroyWindow(window);
    SDL_Quit();

    return true;
}

