import core.thread;
import core.time;
import std.stdio;

import derelict.sdl2.sdl;
import derelict.sdl2.image;

import eventHandler;
import geometry;
import geometry_types;
import globals;
import graphics;
import physics;
import setup_cleanup;
import load_level;

void main()
{
    // Old GTK test. Not used, for now at least.
    // testWindow();

    if (setup()) {
        runGame();
        cleanup();
    }
    else {
        debug writefln("Setup failed; aborting.");
    }
}

void runGame()
{
    Duration frameLength   = dur!"seconds"(1) / FRAME_RATE;
    MonoTime prevStartTime = MonoTime.currTime;

    clearScreen();

    while (!shouldQuit) {
        // Get start time of this iteration.
        MonoTime currStartTime = MonoTime.currTime;

        handleEvents();
        updateGame(currStartTime - prevStartTime);
        renderGame();

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

    playTime += elapsedSeconds;

    debug {
        writefln("Updating game. %s.%07s seconds elapsed.", secs, nsecs / 100);
    }

    updateWorld(elapsedSeconds);
}

