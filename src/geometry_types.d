module geometry_types;

import derelict.sdl2.sdl;

private import units;

struct WorldRect {
    world_length x;
    world_length y;
    world_length w;
    world_length h;

    // Getters and setters for all the reasonable anchor points of a rect
    // (edges, corners, center point) of a rect.
    // Note that setters move the rect, rather than resizing it. Therefore, if
    // you want to move and resize a rect, you should modify the 'w' and 'h'
    // fields first, then set the appropriate anchor.
    // Also note that in world coordinates, (x, y) is the bottom-left corner.

    // Getters for the edges.
    @property world_length   left() const pure { return x;     }
    @property world_length bottom() const pure { return y;     }
    @property world_length  right() const pure { return x + w; }
    @property world_length    top() const pure { return y + h; }

    // Setters for the edges.
    @property void   left(world_length newL) { x = newL;     }
    @property void bottom(world_length newB) { y = newB;     }
    @property void  right(world_length newR) { x = newR - w; }
    @property void    top(world_length newT) { y = newT - h; }

    // Getters for the corners.
    @property WorldPoint BL() const pure { return WorldPoint(x,     y    ); }
    @property WorldPoint BR() const pure { return WorldPoint(x + w, y    ); }
    @property WorldPoint TL() const pure { return WorldPoint(x,     y + h); }
    @property WorldPoint TR() const pure { return WorldPoint(x + w, y + h); }

    // Setters for the corners.
    @property void BL(WorldPoint newBL) { x = newBL.x;     y = newBL.y;     }
    @property void BR(WorldPoint newBR) { x = newBR.x - w; y = newBR.y;     }
    @property void TL(WorldPoint newTL) { x = newTL.x;     y = newTL.y - h; }
    @property void TR(WorldPoint newTR) { x = newTR.x - w; y = newTR.y - h; }

    // Getters for the center point.
    @property world_length centerX() const pure { return x + w / 2; }
    @property world_length centerY() const pure { return y + h / 2; }

    // Setters for the center point.
    @property void centerX(world_length newX) { x = newX - w / 2; }
    @property void centerY(world_length newY) { y = newY - h / 2; }
}

struct WorldPoint {
    world_length x;
    world_length y;
}

alias ScreenRect = SDL_Rect;

// Make sure that D ints and SDL ints are the same size.
static assert(ScreenRect.x.sizeof == int.sizeof);
static assert(ScreenRect.y.sizeof == int.sizeof);

struct ScreenPoint {
    int x;
    int y;
}

