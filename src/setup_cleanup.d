module setup_cleanup;

import std.stdio;

import derelict.sdl2.sdl;
import derelict.util.exception;
import yaml;

import globals;

// Initialize everything. On success, return true. On failure, report the error
// and return false.
bool setup()
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
    initialize_magic_numbers();

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

// Clean up everything that was initialized. On success, return true. On
// failure, report the failure and return false. Not that there's much the
// caller can do about a failure to cleanup....
bool cleanup()
{
    cleanup_objects();
    debug writefln("Exiting.");

    if (window !is null) {
        SDL_DestroyWindow(window);
    }

    // From http://wiki.libsdl.org/SDL_Quit:
    //     "You should call this function even if you have already shutdown
    //      each initialized subsystem with SDL_QuitSubSystem(). It is safe to
    //      call this function even in the case of errors in initialization."
    // Therefore, don't worry about checking if the SDL_Init succeeded.
    SDL_Quit();

    return true;
}

// TODO [#3]: Magic numbers bad.
void initialize_magic_numbers()
{
    Node configRoot = Loader("config/magic.yaml").load();
    // TODO: Actually parse it.
    // // This is so not Windows compatible it's not even funny.
    // debug {
    //     Dumper("/dev/tty").dump(configRoot);
    // }

    // Game state
    player.rect.x = 20;
    player.rect.y = 65;
    player.rect.w = 20;
    player.rect.h = 20;
    player.vel.x = 30;
    player.vel.y = 0;

    platform1.rect.x = 100;
    platform1.rect.y = 80;
    platform1.rect.w = 50;
    platform1.rect.h = 10;
    // Used for converting between world and screen coordinates.
    wViewRect.x = 0;
    wViewRect.y = 0;
    wViewRect.w = 200;
    wViewRect.h = 150;

    sViewRect.x = 0;
    sViewRect.y = 0;
    sViewRect.w = 640;
    sViewRect.h = 480;
    
    // This variable is set to true when it's time to end the program -- perhaps
    // because the user tried to close the window, or they clicked an in-game
    // "Quit" button.
    shouldQuit = false;
}

void cleanup_objects(){
    // Nothing to do right now
}

