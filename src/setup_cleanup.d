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
    bool success = true;

    initializeMagicNumbers();
    success &= setupLibraries();
    success &= setupWindow();

    return success;
}

// TODO [#3]: Magic numbers bad.
void initializeMagicNumbers()
{
    Node configRoot = Loader("config/magic.yaml").load();
    // // This is so not Windows compatible it's not even funny.
    // debug {
    //     Dumper("/dev/tty").dump(configRoot);
    // }

    // FIXME: Finish this.
    // This is a proof of concept for parsing these values from magic.yaml.
    // It's not finished.

    // Parse the YAML.
    if (!configRoot.isMapping) {
        // FIXME: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }

    if (!configRoot.containsKey("screen-view")) {
        // FIXME: Error propagation.
        std.stdio.stderr.writefln(`Error: "screen-view" not present in `
                                  `YAML file.`);
        return;
    }
    Node screenViewNode = configRoot["screen-view"];
    if (!screenViewNode.containsKey("rect")) {
        // FIXME: Error propagation.
        std.stdio.stderr.writefln(`Error: screen-view has no "rect".`);
        return;
    }
    sViewRect = parseScreenRect(screenViewNode["rect"]);

    // TODO: More YAML parsing code goes here.

    ///// Old code to initialize sViewRect.
    // sViewRect.x = 0;
    // sViewRect.y = 0;
    // sViewRect.w = 640;
    // sViewRect.h = 480;

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
    platform1.interactWithPlayer = &scream;

    // Used for converting between world and screen coordinates.
    wViewRect.x = 0;
    wViewRect.y = 0;
    wViewRect.w = 200;
    wViewRect.h = 150;

    // This variable is set to true when it's time to end the program -- perhaps
    // because the user tried to close the window, or they clicked an in-game
    // "Quit" button.
    shouldQuit = false;
}

// Set up everything associated with each library we use.
bool setupLibraries()
{
    bool success = true;

    success &= setupSDL();

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

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Exiting.");

    bool success = true;

    success &= cleanupObjects();
    success &= cleanupWindow();
    success &= cleanupLibraries();

    return true;
}

// Clean up game objects.
bool cleanupObjects()
{
    // Nothing to do right now
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

// Clean up everything associated with each library we're using.
bool cleanupLibraries()
{
    bool success = true;

    success &= cleanupSDL();

    return success;
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

