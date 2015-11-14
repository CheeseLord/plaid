import core.thread;
import core.time;
import std.stdio;

import derelict.sdl2.sdl;

import eventHandler;
import geometry;
import geometry_types;
import globals;
import physics;

void main()
{
    // Old GTK test. Not used, for now at least.
    // testWindow();

    // Set up SDL.
    DerelictSDL2.load();
    SDL_Init(SDL_INIT_VIDEO);

    // Create a window.
    window = SDL_CreateWindow("Plaid",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        640, 480, SDL_WINDOW_OPENGL);

    if (window is null) {
        writefln("Error: failed to create window.");
        return;
    }

    // Clean this all up when we're done.
    scope (exit) {
        writefln("Exiting.");
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    runGame();
}

void runGame()
{
    SDL_Surface *surface = SDL_GetWindowSurface(window);
    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));

    Duration frameLength = dur!"seconds"(1) / FRAME_RATE;

    MonoTime prevStartTime = MonoTime.currTime;

    while (!shouldQuit) {
        // Get start time of this iteration.
        MonoTime currStartTime = MonoTime.currTime;

        // Quit when someone tries to close the window:
        handleEvents();

        // Simulate game forward.
        updateGame(currStartTime - prevStartTime);

        // Draw game state.
        renderGame(surface);

        // Update screen.
        SDL_UpdateWindowSurface(window);

        // If we haven't used a full frame worth of time, sleep for the rest of
        // the frame.
        prevStartTime = currStartTime;
        Duration timeToSleep = frameLength -
                               (MonoTime.currTime - currStartTime);
        if (!timeToSleep.isNegative) {
            Thread.sleep(timeToSleep);
        }
    }
}

void updateGame(Duration elapsedTime)
{
    // Convert the elaped time to seconds.
    long secs, nsecs;
    elapsedTime.split!("seconds", "nsecs")(secs, nsecs);
    double elapsedSeconds = cast(double)(secs) + 1.0e-9 * cast(double)(nsecs);

    debug {
        writefln("Updating game. %s.%07s seconds elapsed.", secs, nsecs / 100);
    }

    applyGravity(player, elapsedSeconds);
    enforceGround(player);
    player.rect.x += player.vel.x * elapsedSeconds;
    player.rect.y += player.vel.y * elapsedSeconds;
}

void renderGame(SDL_Surface *surface)
{
    ScreenRect sPlayerRect = worldToScreenRect(player.rect);

    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));
    SDL_FillRect(surface, &sPlayerRect, SDL_MapRGB(surface.format, 0, 0, 0));
}
