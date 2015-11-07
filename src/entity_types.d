module entity_types;

// TODO [#4]: Track coordinates in world coordinates, not screen coordinates.
import derelict.sdl2.sdl;

// TODO [#4]: Track coordinates in world coordinates, not screen coordinates.
alias HitRect = SDL_Rect;

struct Velocity {
    int x;
    int y;
}

struct Player {
    HitRect  rect;
    Velocity vel;
}

