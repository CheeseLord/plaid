module SDLExample;

import std.stdio;
import core.time;
import core.thread;

import derelict.sdl2.sdl;

// TODO: Magic numbers bad.
// TODO: Track coordinates in world coordinates, not screen coordinates.
SDL_Rect playerRect = {
    x: 50,
    y: 230,
    w: 20,
    h: 20
};

void testSDL()
{
    // Set up SDL.
    DerelictSDL2.load();
    SDL_Init(SDL_INIT_VIDEO);

    // Create a window.
    SDL_Window *window = SDL_CreateWindow("Plaid",
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

    SDL_Surface *surface = SDL_GetWindowSurface(window);
    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));

    const int frameRate = 20;
    Duration frameLength = dur!"seconds"(1) / frameRate;

    MonoTime prevStartTime = MonoTime.currTime;

    MAIN_LOOP: while (true) {
        // Get start time of this iteration.
        MonoTime currStartTime = MonoTime.currTime;

        // Quit when someone tries to close the window:
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                break MAIN_LOOP;
            }
        }

        // Simulate game forward.
        UpdateGame(currStartTime - prevStartTime);

        // Draw game state.
        RenderGame(surface);

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

void UpdateGame(Duration elapsedTime)
{
    // Convert the elaped time to seconds.
    long secs, nsecs;
    elapsedTime.split!("seconds", "nsecs")(secs, nsecs);
    double elapsedSeconds = cast(double)(secs) + 1.0e-9 * cast(double)(nsecs);

    debug {
        writefln("Updating game. %s.%07s seconds elapsed.", secs, nsecs / 100);
    }

    playerRect.x += cast(int)(100 * elapsedSeconds);

    debug {
        writefln("Player x is %s.", playerRect.x);
    }
}

void RenderGame(SDL_Surface *surface)
{
    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));
    SDL_FillRect(surface, &playerRect, SDL_MapRGB(surface.format, 0, 0, 0));
}
