module graphics;

import std.algorithm: max;
import std.stdio;

import derelict.sdl2.image;
import derelict.sdl2.sdl;

import geometry;
import geometry_types;
import globals;


private SDL_Window  *window;
private SDL_Surface *playerSprite;
private SDL_Surface *unscaledPlayerSprite;


///////////////////////////////////////////////////////////////////////////////
// Setup and cleanup

// Set up the game window.
bool setupGraphics()
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

    // TODO [#30]: If this fails, we should clean up the window.
    return loadSprites();
}

// Load all the sprites.
// If there are more, we might not want to load them all at the start.
private bool loadSprites()
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

bool cleanupGraphics()
{
    if (window !is null) {
        SDL_DestroyWindow(window);
    }

    return true;
}



///////////////////////////////////////////////////////////////////////////////
// Main rendering logic

void renderGame()
{
    SDL_Surface *surface = SDL_GetWindowSurface(window);

    ScreenRect sPlayerRect = worldToScreenRect(player.rect);
    ScreenRect sPlatformRect;

    clearScreen();
    foreach (platform; platforms) {
        sPlatformRect = worldToScreenRect(platform.rect);
        SDL_FillRect(surface, &sPlatformRect,
                     SDL_MapRGB(surface.format, 127, 0, 0));
    }
    SDL_BlitSurface(playerSprite, null, surface, &sPlayerRect);

    SDL_UpdateWindowSurface(window);
}

void clearScreen()
{
    SDL_Surface *surface = SDL_GetWindowSurface(window);
    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));
}
