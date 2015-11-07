module geometry;

import geometry_types;
import globals;


ScreenPoint worldToScreenPoint(WorldPoint wPoint)
{
    double xScale = cast(double)(sViewRect.w) / cast(double)(wViewRect.w);
    double yScale = cast(double)(sViewRect.h) / cast(double)(wViewRect.h);

    // Note that y is inverted: positive y is up in the world, but down on the
    // screen.
    // FIXME [#10]: I'm pretty sure these are wrong.
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

    // Convert the position.
    WorldPoint  wPoint = {x: wRect.x, y: wRect.y};
    ScreenPoint sPoint = worldToScreenPoint(wPoint);

    ScreenRect sRect = {
        x: sPoint.x,
        y: sPoint.y,
        w: cast(int)(wRect.w * xScale),
        h: cast(int)(wRect.h * yScale),
    };

    return sRect;
}

// TODO [#11]: Screen to world

