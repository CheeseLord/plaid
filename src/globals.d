module globals;

import derelict.sdl2.sdl;

import entity_types;

// Constants
immutable int frameRate = 20;

immutable int gravity = 200;


// Game state

// TODO [#3]: Magic numbers bad.
Player player = {
    rect: {
        x: 50,
        y: 230,
        w: 20,
        h: 20,
    },
    vel: {
        x: 100,
        y: 0,
    },
};


// Other globals
SDL_Window *window;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

