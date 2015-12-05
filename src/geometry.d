module geometry;

import geometry_types;
import globals;


ScreenPoint worldToScreenPoint(WorldPoint wPoint)
{
    double xScale = cast(double)(sViewRect.w) / cast(double)(wViewRect.w);
    double yScale = cast(double)(sViewRect.h) / cast(double)(wViewRect.h);

    // y is inverted: positive y is up in the world, but down on the screen.
    // This means that in the world, the 'y' in a Point refers to the distance
    // from the bottom, but in the screen, it refers to the distance from the
    // top. As such, when converting, we need to subtract it from the height
    // of the ViewRect.
    ScreenPoint sPoint = {
        x: cast(int)(sViewRect.x + xScale * (wPoint.x - wViewRect.x)),
        y: cast(int)(sViewRect.y + sViewRect.h -
                     yScale * (wPoint.y - wViewRect.y)),
    };

    return sPoint;
}

ScreenRect worldToScreenRect(WorldRect wRect)
{
    double xScale = cast(double)(sViewRect.w) / cast(double)(wViewRect.w);
    double yScale = cast(double)(sViewRect.h) / cast(double)(wViewRect.h);

    // We can't simply convert (x, y), because (x, y) is the bottom-left corner
    // in the world and the top-left corner on the screen. Instead, compute the
    // top-left corner and then convert it.
    WorldPoint  wTopLeft = {x: wRect.x, y: wRect.y + wRect.h};
    ScreenPoint sTopLeft = worldToScreenPoint(wTopLeft);

    ScreenRect sRect = {
        x: sTopLeft.x,
        y: sTopLeft.y,
        w: cast(int)(wRect.w * xScale),
        h: cast(int)(wRect.h * yScale),
    };

    return sRect;
}

// TODO [#11]: Screen to world


bool rectsIntersect(WorldRect rectA, WorldRect rectB)
{
    // It's easier to check where we don't intersect.
    if (rectA.right <= rectB.left  ) { return false; }
    if (rectB.right <= rectA.left  ) { return false; }
    if (rectA.top   <= rectB.bottom) { return false; }
    if (rectB.top   <= rectA.bottom) { return false; }

    return true;
}

