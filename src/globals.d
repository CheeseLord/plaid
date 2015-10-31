module globals;

import derelict.sdl2.sdl;

// TODO: Magic numbers bad.
// TODO: Track coordinates in world coordinates, not screen coordinates.
SDL_Rect playerRect = {
    x: 50,
    y: 230,
    w: 20,
    h: 20
};

SDL_Window *window;

