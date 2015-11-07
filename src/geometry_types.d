module geometry_types;

import derelict.sdl2.sdl;

struct WorldRect {
    double x;
    double y;
    double w;
    double h;
}

struct WorldPoint {
    double x;
    double y;
}

alias ScreenRect = SDL_Rect;

// Make sure that D ints and SDL ints are the same size.
static assert(ScreenRect.x.sizeof == int.sizeof);
static assert(ScreenRect.y.sizeof == int.sizeof);

struct ScreenPoint {
    int x;
    int y;
}

