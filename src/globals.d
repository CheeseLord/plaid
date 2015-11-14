module globals;

import derelict.sdl2.sdl;

import geometry_types;
import entity_types;

// Constants
immutable int FRAME_RATE = 20;

immutable int GRAVITY = -50;


// Game state

// TODO [#3]: Magic numbers bad.
Player player = {
    rect: {
        x: 20,
        y: 65,
        w: 20,
        h: 20,
    },
    vel: {
        x: 30,
        y: 0,
    },
};


// Other globals
SDL_Window *window;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

// Used for converting between world and screen coordinates.
// TODO [#3]: Magic numbers bad
WorldRect  wViewRect = {
    x: 0,
    y: 0,
    w: 200,
    h: 150,
};
ScreenRect sViewRect = {
    x: 0,
    y: 0,
    w: 640,
    h: 480,
};

