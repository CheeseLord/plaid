module globals;

import derelict.sdl2.sdl;

public import geometry_types;
public import entity_types;

// Constants
immutable int FRAME_RATE = 20;
immutable int MIN_SCREEN_WIDTH  = 80;
immutable int MIN_SCREEN_HEIGHT = 60;

double gravity;
double worldScrollRate;

double playerWalkSpeed;
double playerJumpStrength;


// Game state
Player player;
Platform[] platforms;
PlayerState playerState = PlayerState.FALLING;
string currentLevel;

// Other globals
// TODO [#27]: Move these to graphics.d
SDL_Window *window;
SDL_Surface *playerSprite;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

// Used for converting between world and screen coordinates.
WorldRect  wViewRect;
ScreenRect sViewRect;

