module setup_cleanup;

import std.stdio;
import std.algorithm: max;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import derelict.util.exception;
import yaml;

import geometry;
import globals;
import platform_functions;
import yaml_parser;
import load_level;

// Initialize everything.
// Returns:
//      1 -- success
//      0 -- failure
//     -1 -- complete failure; abort without cleanup
// TODO [#3]: Magic(?) numbers bad.
int setup()
{
    debug writefln("Setting up.");

    if (!setupLibraries()) {
        return -1;
    }

    initializeMagicNumbers();

    bool success = setupWindow()    &&
                   setupObjects()   &&
                   loadSprites();

    return success ? 1 : 0;
}

// Clean up everything that was initialized.
bool cleanup()
{
    debug writefln("Cleaning up.");

    return cleanupObjects()   &&
           cleanupWindow()    &&
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
// TODO [#27]: Maybe move to graphics.d?
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

// Set up the game window.
// TODO [#27]: Move to graphics.d
bool setupWindow()
{
    // Make sure the user can't create a zero-sized window by messing with the
    // config files.
    sViewRect.w = max(sViewRect.w, MIN_SCREEN_WIDTH);
    sViewRect.h = max(sViewRect.h, MIN_SCREEN_HEIGHT);

    // Create a window.
    window = SDL_CreateWindow("Plaid",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        sViewRect.w, sViewRect.h, SDL_WINDOW_OPENGL);

    if (window is null) {
        printf("Error: Failed to create window for plaid: %s\n",
               SDL_GetError());
        return false;
    }

    return true;
}

// Clean up the game window.
// TODO [#27]: Move to graphics.d
bool cleanupWindow()
{
    if (window !is null) {
        SDL_DestroyWindow(window);
    }

    return true;
}

// Load all the sprites.
// If there are more, we might not want to load them all at the start.
// TODO [#27]: Move to graphics.d
bool loadSprites()
{
    // TODO [#28]: Do we ever free this? Should we?
    unscaledPlayerSprite = IMG_Load("resources/sprites/player.png");
    if (unscaledPlayerSprite is null) {
        printf("Error: IMG_Load failed.\n%s\n", SDL_GetError());
        return false;
    }

    // When the unscaledPlayerSprite is blitted onto another surface, replace
    // the alpha values of the affected pixels. This is necessary because we're
    // copying it onto an intermediate surface (playerSprite) before we
    // actually blit it onto the screen.
    SDL_SetSurfaceBlendMode(unscaledPlayerSprite, SDL_BLENDMODE_NONE);

    // Note: we'll eventually need to move this somewhere else, so it can be
    // called when the window is resized.
    // Note: Calling SDL_ConvertSurface might make it faster to repeatedly blit
    // playerSprite onto the screen.
    ScreenRect sPlayerRect = worldToScreenRect(player.rect);
    sPlayerRect.x = 0;
    sPlayerRect.y = 0;
    // TODO [#28]: We don't free this.
    playerSprite = createSimilarSurface(unscaledPlayerSprite,
                                        sPlayerRect.w, sPlayerRect.h);
    if (playerSprite is null) {
        printf("Error: Failed to create player surface: %s\n", SDL_GetError());
        return false;
    }
    SDL_BlitScaled(unscaledPlayerSprite, null, playerSprite, &sPlayerRect);

    return true;
}

// Create a surface similar to similarTo, but with different dimensions.
// TODO [#27]: Move to graphics.d
private SDL_Surface* createSimilarSurface(SDL_Surface* similarTo,
                                          int width, int height)
{
    return SDL_CreateRGBSurface(
        0,  // http://wiki.libsdl.org/SDL_CreateRGBSurface --
            // "the flags are unused and should be set to 0"
        width,
        height,
        similarTo.format.BitsPerPixel,
        similarTo.format.Rmask,
        similarTo.format.Gmask,
        similarTo.format.Bmask,
        similarTo.format.Amask);
}

