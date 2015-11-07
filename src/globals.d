module globals;

import derelict.sdl2.sdl;

// Constants
const int frameRate = 20;

// TODO: Magic numbers bad.
// TODO: Track coordinates in world coordinates, not screen coordinates.
SDL_Rect playerRect = {
    x: 50,
    y: 230,
    w: 20,
    h: 20
};

int xVel = 100;
int yVel = 0;
int gravity = 200;

SDL_Window *window;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

