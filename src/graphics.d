module graphics;

import std.algorithm: max;
import std.stdio;

import derelict.sdl2.image;
import derelict.sdl2.sdl;

import geometry;
import geometry_types;
import globals;


// TODO [#3]: Magic numbers bad.
immutable int    NUM_PLAYER_SPRITES       = 2;
immutable double ANIMATION_FRAME_LENGTH   = 0.3;
immutable double ANIMATION_PROGRESS_RESET = 100 * ANIMATION_FRAME_LENGTH;

private SDL_Window* window;

// TODO [#41]: Handle sprite sizing elsewhere.
private int playerSpriteWidth;
private int playerSpriteHeight;
private SDL_Surface* playerSprites;
private SDL_Surface* unscaledPlayerSprites;

private SDL_Surface* platformSprite;

private double animationProgress = 0;


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
    unscaledPlayerSprites = IMG_Load("resources/sprites/player.png");
    if (unscaledPlayerSprites is null) {
        printf("Error: IMG_Load failed.\n%s\n", SDL_GetError());
        return false;
    }

    // When the unscaledPlayerSprites is blitted onto another surface, replace
    // the alpha values of the affected pixels. This is necessary because we're
    // copying it onto an intermediate surface (playerSprites) before we
    // actually blit it onto the screen.
    SDL_SetSurfaceBlendMode(unscaledPlayerSprites, SDL_BLENDMODE_NONE);

    // Note: we'll eventually need to move this somewhere else, so it can be
    // called when the window is resized.
    // Note: Calling SDL_ConvertSurface might make it faster to repeatedly blit
    // playerSprites onto the screen.
    // TODO [#41]: Handle sprite sizing elsewhere.
    ScreenRect sPlayerRect = worldToScreenRect(player.rect);
    playerSpriteWidth  = sPlayerRect.w;
    playerSpriteHeight = sPlayerRect.h;
    // TODO [#28]: We don't free this.
    playerSprites = createSimilarSurface(unscaledPlayerSprites,
                                         playerSpriteWidth * NUM_PLAYER_SPRITES,
                                         playerSpriteHeight);
    if (playerSprites is null) {
        printf("Error: Failed to create player surface: %s\n", SDL_GetError());
        return false;
    }

    SDL_BlitScaled(unscaledPlayerSprites, null,
                   playerSprites, null);

    // TODO [#28]: We never free this. Should we?
    platformSprite = IMG_Load("resources/sprites/platform.png");
    if (platformSprite is null) {
        printf("Error: IMG_Load failed.\n%s\n", SDL_GetError());
        return false;
    }

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

void renderGame(double elapsedSeconds)
{
    animationProgress += elapsedSeconds;
    animationProgress %= ANIMATION_PROGRESS_RESET;

    SDL_Surface* surface = SDL_GetWindowSurface(window);

    ScreenRect sPlayerRect = worldToScreenRect(player.rect);

    clearScreen();
    foreach (const ref platform; platforms) {
        drawPlatform(surface, platform);
    }

    int animationFrameNumber = cast(int)(animationProgress /
                                         ANIMATION_FRAME_LENGTH);
    ScreenRect sPlayerSpriteRect = {
        x: (animationFrameNumber % NUM_PLAYER_SPRITES) * playerSpriteWidth,
        y: 0,
        w: playerSpriteWidth,
        h: playerSpriteHeight,
    };
    SDL_BlitSurface(playerSprites, &sPlayerSpriteRect, surface, &sPlayerRect);

    SDL_UpdateWindowSurface(window);
}

void clearScreen()
{
    SDL_Surface* surface = SDL_GetWindowSurface(window);
    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));
}

void drawPlatform(SDL_Surface* surface, const ref Platform platform)
{
    if (platform.invisible) {
        return;
    }

    const(ScreenRect) wholeRect = worldToScreenRect(platform.rect);

    if (platform.bouncy) {
        // We want to "coat" the platform in a yellowish-orange bouncy
        // material. To draw this, just make a slightly larger rectangle of the
        // bouncy coating and then draw the platform over the middle part of
        // it.

        // TODO [#3]: magic numbers bad.
        immutable int BOUNCY_COATING_WIDTH = 3;

        ScreenRect expandedRect = wholeRect;
        expandedRect.x -=     BOUNCY_COATING_WIDTH;
        expandedRect.y -=     BOUNCY_COATING_WIDTH;
        expandedRect.w += 2 * BOUNCY_COATING_WIDTH;
        expandedRect.h += 2 * BOUNCY_COATING_WIDTH;
        SDL_FillRect(surface, &expandedRect,
                     // TODO [#3]: magic numbers bad.
                     SDL_MapRGB(surface.format, 255, 179, 0));
    }

    int minX = wholeRect.x;
    int minY = wholeRect.y;
    int maxX = minX + wholeRect.w;
    int maxY = minY + wholeRect.h;

    for (int y = minY; y < maxY; y += platformSprite.h) {
        for (int x = minX; x < maxX; x += platformSprite.w) {
            ScreenRect destRect = {
                x: x,
                y: y,
                w: 0,
                h: 0,
            };
            ScreenRect sourceRect = {
                x: 0,
                y: 0,
                w: maxX - destRect.x,
                h: maxY - destRect.y,
            };
            SDL_BlitSurface(platformSprite, &sourceRect, surface, &destRect);
        }
    }
}

