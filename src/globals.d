module globals;

import derelict.sdl2.sdl;

import geometry_types;
import entity_types;

// Constants
immutable int FRAME_RATE = 20;

// TODO [#3] These should both be parsed from the YAML.
double GRAVITY = -50;
double worldScrollRate = 5;

// Game state
Player player;
Platform[] platforms;

// Other globals
SDL_Window *window;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

// Used for converting between world and screen coordinates.
WorldRect  wViewRect;
ScreenRect sViewRect;

