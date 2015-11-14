module geometry_types;

import derelict.sdl2.sdl;

struct WorldRect {
    double x;
    double y;
    double w;
    double h;

    // Getters and setters for all the reasonable anchor points of a rect
    // (edges, corners, center point) of a rect.
    // Note that setters move the rect, rather than resizing it. Therefore, if
    // you want to move and resize a rect, you should modify the 'w' and 'h'
    // fields first, then set the appropriate anchor.
    // Also note that in world coordinates, (x, y) is the bottom-left corner.

    // Getters for the edges.
    @property double   left() const pure { return x;     }
    @property double bottom() const pure { return y;     }
    @property double  right() const pure { return x + w; }
    @property double    top() const pure { return y + h; }

    // Setters for the edges.
    @property void   left(double newL) { x = newL;     }
    @property void bottom(double newB) { y = newB;     }
    @property void  right(double newR) { x = newR - w; }
    @property void    top(double newT) { y = newT - h; }

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
    @property double centerX() const pure { return x + w / 2; }
    @property double centerY() const pure { return y + h / 2; }

    // Setters for the center point.
    @property void centerX(double newX) { x = newX - w / 2; }
    @property void centerY(double newY) { y = newY - h / 2; }
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

