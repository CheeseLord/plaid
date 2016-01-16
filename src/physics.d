module physics;

private import std.stdio;
private import std.math;
private import std.algorithm;

private import entity_types;
private import geometry;
private import globals;


enum Direction {LEFT, UP, RIGHT, DOWN};


void updateWorld(double elapsedSeconds)
{
    applyGravity(elapsedSeconds);
    updatePosition(elapsedSeconds, 0);
    updateView(elapsedSeconds);
}


void applyGravity(double elapsedSeconds)
{
    player.vel.y += GRAVITY * elapsedSeconds;
}


void updateView(double elapsedSeconds)
{
    wViewRect.y += (worldScrollRate * elapsedSeconds);
}


void updatePosition(double elapsedSeconds, size_t recursionDepth)
{
    // TODO [#3]: Magic numbers bad.
    // If we hit the maximum recursion depth, something has gone very wrong
    // elsewhere, and we have some fun debugging to do.
    assert (recursionDepth < 20);

    debug (player_pos) {
        writefln("x = %0.2f, y = %0.2f", player.rect.left, player.rect.bottom);
    }

    // TODO [#3]: Magic numbers bad.
    double GROUND_HEIGHT = 20.0;

    HitRect endRect = getNewPosition(player.rect, player.vel, elapsedSeconds);

    bool      collides = false;
    Platform  firstCollisionPlatform;
    double    firstCollisionTime = elapsedSeconds;
    Direction firstCollisionDirection;

    double    collisionTime;
    Direction collisionDirection;
    foreach (platform; platforms) {
        if (entityCollides(player.rect, endRect, platform.rect,
                           elapsedSeconds,
                           collisionTime, collisionDirection)) {
            collides = true;
            if (collisionTime < firstCollisionTime) {
                firstCollisionPlatform = platform;
                firstCollisionTime = collisionTime;
                firstCollisionDirection = collisionDirection;
            }
        }
    }

    if (collides) {
        player.rect = getNewPosition(player.rect, player.vel,
                                     firstCollisionTime);

        // TODO [#19]: Make the interaction update the velocity instead.
        firstCollisionPlatform.interactWithPlayer(firstCollisionPlatform, player);

        // TODO [#19]: Make the interaction update the velocity instead.
        // Set only the component of the player's velocity that moves them into
        // the platform to zero. Leave the other component unchanged.
        switch (firstCollisionDirection) {
            case Direction.RIGHT: player.vel.x = min(player.vel.x, 0); break;
            case Direction.LEFT:  player.vel.x = max(player.vel.x, 0); break;
            case Direction.UP:    player.vel.y = min(player.vel.y, 0); break;
            case Direction.DOWN:  player.vel.y = max(player.vel.y, 0); break;
            default: break;
        }

        if (player.rect.bottom < GROUND_HEIGHT && player.vel.y <= 0) {
            player.rect.bottom = GROUND_HEIGHT;
            player.vel.y = 0;
        }

        // Simulate the rest of the frame.
        updatePosition(elapsedSeconds - firstCollisionTime,
                       recursionDepth + 1);
    }

    else {
        player.rect = getNewPosition(player.rect, player.vel,
                                     firstCollisionTime);

        if (player.rect.bottom < GROUND_HEIGHT && player.vel.y <= 0) {
            player.rect.bottom = GROUND_HEIGHT;
            player.vel.y = 0;
        }
    }
}


pure HitRect getNewPosition(HitRect rect, Velocity vel, double elapsedSeconds)
{
    // TODO [#18]: Make motion nonlinear.
    double newX = rect.x + elapsedSeconds * vel.x;
    double newY = rect.y + elapsedSeconds * vel.y;

    return HitRect(newX, newY, rect.w, rect.h);
}


/**
 * Check if an entity collides with an obstacle. If so, then also set
 * collisionTime to the amount of time elapsed when the entity first touches
 * the obstacle and collisionDirection to the direction in which the collision
 * occurs. collisionDirection is determined based on the edge of the obstacle
 * that the entity collides with, not the entity's velocity -- so if the entity
 * is moving quickly to the right and just a little bit down, and it skims the
 * top edge of the obstacle, that's a downward collision, not a rightward
 * collision.
 *
 * A collision only counts as a collision if the component of the entity's
 * velocity across the edge of the obstacle that it collides with is nonzero.
 * So, if the entity is moving perfectly vertically, it cannot collide with the
 * left or right edge of the obstacle.
 *
 * The obstacle is located at 'obstacle', and assumed not to move. The entity
 * moves from 'start' to 'end', over a duration 'elapsedTime'.  The entity's
 * start and end must have the same width and height.
 */
private bool entityCollides(HitRect start, HitRect end, HitRect obstacle,
                            double elapsedTime, out double collisionTime,
                            out Direction collisionDirection)
{
    // The direction of the collision, if there is a collision.
    Direction maybeCollisionDir;

    // The entity is assumed not to change size; that would complicate the
    // collision-detection code considerably.
    assert(abs(end.w - start.w) <  1.0e-6);
    assert(abs(end.h - start.h) <  1.0e-6);

    // The later calculations will fail if the entity doesn't move, so handle
    // that here as a special case.
    if (abs(end.y - start.y) < 1.0e-6 && abs(end.x - start.x) < 1.0e-6) {
        return false;
    }

    // Expand obstacle left by the width of entity and down by the height of
    // entity. This allows us to check for collisions between the bottom-left
    // corner of entity and the expanded obstacle. Collision detection between
    // a moving point and a rect is easier than between a moving rect and a
    // rect.
    HitRect expandedObstacle = {
        x: obstacle.x - start.w,
        y: obstacle.y - start.h,
        w: obstacle.w + start.w,
        h: obstacle.h + start.h,
    };

    WorldPoint intersection;
    if (trajectoryIntersects(start.BL, end.BL, expandedObstacle,
                             intersection, maybeCollisionDir)) {
        // What fraction of the elapsedTime elapsed before the collision?
        double collisionFraction;

        // Use whichever axis we moved farther along to convert the
        // intersection point to a fraction of time elapsed. We are safe from
        // division by zero here because the entity is required to move.
        if (abs(end.y - start.y) > abs(end.x - start.x))
            collisionFraction = (intersection.y - start.y) / (end.y - start.y);
        else
            collisionFraction = (intersection.x - start.x) / (end.x - start.x);

        // A collision only counts as a collision if the entity is moving
        // toward the edge of the obstacle with which it collides. For example,
        // in order to collide with the left edge of an obstacle, the entity
        // has to actually be moving to the right. This check is needed to
        // prevent the player from getting "stuck" to a platform -- without it,
        // once the player is touching a platform, we detect a collision right
        // at the start of every frame, even if the player is trying to move
        // away from the platform.
        // TODO [#16]: Will this actually be necessary once we fix #12?
        if     ((maybeCollisionDir == Direction.RIGHT && end.x > start.x) ||
                (maybeCollisionDir == Direction.LEFT  && end.x < start.x) ||
                (maybeCollisionDir == Direction.UP    && end.y > start.y) ||
                (maybeCollisionDir == Direction.DOWN  && end.y < start.y)) {
            collisionTime      = elapsedTime * collisionFraction;
            collisionDirection = maybeCollisionDir;
            return true;
        }
    }

    return false;
}

/**
 * Check if a moving point collides with an obstacle. The point moves from
 * 'start' to 'end'; the obstacle is located at 'obstacle'. If it does collide,
 * set firstIntersection to the first coordinates along the point's trajectory
 * at which it intersects the obstacle and collisionDirection to the direction
 * of the collision. The direction of the collision is determined according to
 * which edge of the obstacle's HitRect the point enters through: for example,
 * if the point enters through the left edge, then this is a rightward
 * collision.
 */
private bool trajectoryIntersects(WorldPoint start, WorldPoint end,
                                  HitRect obstacle,
                                  out WorldPoint firstIntersection,
                                  out Direction  collisionDirection)
{
    // High-level explanation:
    //
    // The start point will fall within one of 9 regions, defined by the
    // obstacle rect:
    //
    //           .       .
    //       TL  .   T   .  TR
    //           .       .
    //     . . . +-------+ . . .
    //           |       |
    //        L  |   C   |   R
    //           |       |
    //     . . . +-------+ . . .
    //           .       .
    //       BL  .   B   .  BR
    //           .       .
    //
    // If it's in C, then the point definitely collides with the obstacle, and
    // its first intersection is start.
    //
    // If it's not in C, then the only way the point can collide with the
    // obstacle is if its trajectory intersects one of the four edges of the
    // rect (that is, it must enter the rect at some point). If it intersects
    // exactly one of them (that is, it ends inside the rect), then our job is
    // also easy; we just need to return that point of intersection. But it's
    // also possible that the point will go all the way through the rect in one
    // frame. This is where the regions are helpful.
    //
    // If the point starts in L, T, R, or B, then there is only one edge it can
    // possibly enter through: respectively the left, top, right, or bottom.
    // If it starts in TL, TR, BL, or BR, then there are two edges it can enter
    // through (for TL the top and left, for TR the top and right, and so on),
    // and it can't exit through either of those two. This means that all we
    // need to do is check for intersections with the possible entry edges,
    // determined based on the point's starting region.
    //
    // The logic for that can be re-expressed as follows:
    //     If we're in TL, L, or BL, check for intersection with left   edge.
    //     If we're in TL, T, or TR, check for intersection with top    edge.
    //     If we're in TR, R, or BR, check for intersection with right  edge.
    //     If we're in BL, B, or BR, check for intersection with bottom edge.

    // Is the start point outside of the obstacle?
    bool isStartOutside = false;

    // If we're in TL, L, or BL, check for intersection with left   edge.
    if (start.x < obstacle.left) {
        isStartOutside = true;
        if (segmentIntersectsVertical(start, end, obstacle.TL, obstacle.BL,
                                      firstIntersection)) {
            collisionDirection = Direction.RIGHT;
            return true;
        }
    }
    // If we're in TR, R, or BR, check for intersection with right  edge.
    else if (start.x > obstacle.right) {
        isStartOutside = true;
        if (segmentIntersectsVertical(start, end, obstacle.TR, obstacle.BR,
                                      firstIntersection)) {
            collisionDirection = Direction.LEFT;
            return true;
        }
    }

    // If we're in TL, T, or TR, check for intersection with top    edge.
    if (start.y > obstacle.top) {
        isStartOutside = true;
        if (segmentIntersectsHorizontal(start, end, obstacle.TL, obstacle.TR,
                                        firstIntersection)) {
            collisionDirection = Direction.DOWN;
            return true;
        }
    }
    // If we're in BL, B, or BR, check for intersection with bottom edge.
    else if (start.y < obstacle.bottom) {
        isStartOutside = true;
        if (segmentIntersectsHorizontal(start, end, obstacle.BL, obstacle.BR,
                                        firstIntersection)) {
            collisionDirection = Direction.UP;
            return true;
        }
    }

    // If none of the four checks above triggered, then the only region we can
    // be in is C.
    if (!isStartOutside) {
        // In this case, the intersection happens immediately.
        firstIntersection  = start;

        // Calculate the collision direction based on which edge we're
        // "closest" to. More precisely, divide the obstacle rect into the
        // quadrants formed by its two diagonals; whichever quadrant the point
        // falls in, treat the collision as if it were entering the obstacle
        // through the corresponding edge.
        if     (abs(start.x - obstacle.centerX) / obstacle.w >
                abs(start.y - obstacle.centerY) / obstacle.h) {
            if (start.x < obstacle.centerX)
                collisionDirection = Direction.RIGHT;
            else
                collisionDirection = Direction.LEFT;
        }
        else {
            if (start.y < obstacle.centerY)
                collisionDirection = Direction.UP;
            else
                collisionDirection = Direction.DOWN;
        }

        return true;
    }

    // If none of the above checks found an intersection, then there isn't one.
    return false;
}

/**
 * Check whether two line segments intersect. One segment goes from s1Start to
 * s1End; the other goes from s2Start to s2End. The second one must be
 * perfectly vertical. If they do intersect, store the point of intersection in
 * intersection.
 */
private bool segmentIntersectsVertical(WorldPoint s1Start, WorldPoint s1End,
                                       WorldPoint s2Start, WorldPoint s2End,
                                       out WorldPoint intersection)
{
    // s2Start.x and s2End.x are assumed equal.
    assert(abs(s2End.x - s2Start.x) < 1.0e-6);
    double s2x = s2Start.x;

    if     ((s1Start.x < s2x && s1End.x > s2x) ||
            (s1Start.x > s2x && s1End.x < s2x)) {
        // Segment 1 starts and ends on opposite sides (horizontally speaking)
        // of segment 2, so an intersection is possible.

        // Compute the y-coordinate of segment 1 at s2x. If the two segments
        // intersect, it must be at this y-coordinate, so we call it
        // intersectY. To find this coordinate, we make use of the fact that:
        //      intersectY - s1Start.y       s1End.y - s1Start.y
        //     ------------------------  =  ---------------------
        //             s2x - s1Start.x       s1End.x - s1Start.x
        double intersectY = (s1End.y - s1Start.y) / (s1End.x - s1Start.x) *
                            (s2x - s1Start.x) +
                            s1Start.y;

        if     ((s2Start.y < intersectY && intersectY < s2End.y) ||
                (s2Start.y > intersectY && intersectY > s2End.y)) {
            // The segments intersect.
            intersection = WorldPoint(s2x, intersectY);
            return true;
        }
    }

    return false;
}

/**
 * Check whether two line segments intersect. One segment goes from s1Start to
 * s1End; the other goes from s2Start to s2End. The second one must be
 * perfectly horizontal. If they do intersect, store the point of intersection
 * in intersection.
 */
private bool segmentIntersectsHorizontal(WorldPoint s1Start, WorldPoint s1End,
                                         WorldPoint s2Start, WorldPoint s2End,
                                         out WorldPoint intersection)
{
    // s2Start.y and s2End.y are assumed equal.
    assert(abs(s2End.y - s2Start.y) < 1.0e-6);
    double s2y = s2Start.y;

    if     ((s1Start.y < s2y && s1End.y > s2y) ||
            (s1Start.y > s2y && s1End.y < s2y)) {
        // Segment 1 starts and ends on opposite sides (vertically speaking)
        // of segment 2, so an intersection is possible.

        // Compute the x-coordinate of segment 1 at s2y. If the two segments
        // intersect, it must be at this x-coordinate, so we call it
        // intersectX. To find this coordinate, we make use of the fact that:
        //      intersectX - s1Start.x       s1End.x - s1Start.x
        //     ------------------------  =  ---------------------
        //             s2y - s1Start.y       s1End.y - s1Start.y
        double intersectX = (s1End.x - s1Start.x) / (s1End.y - s1Start.y) *
                            (s2y - s1Start.y) +
                            s1Start.x;

        if     ((s2Start.x < intersectX && intersectX < s2End.x) ||
                (s2Start.x > intersectX && intersectX > s2End.x)) {
            // The segments intersect.
            intersection = WorldPoint(intersectX, s2y);
            return true;
        }
    }

    return false;
}

