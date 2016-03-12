module entity_types;

private import std.bitmanip;

private import geometry_types;
public  import geometry_types: WorldPoint;

alias HitRect = WorldRect;

struct Velocity {
    double x;
    double y;
}

struct Player {
    HitRect  rect;
    Velocity vel;
}

struct Platform {
    HitRect rect;

    // Various properties of the platform.
    // These are accessed as bool members of Platform, for example:
    //     if (somePlatform.passthru) { doSomething(); }
    mixin(bitfields!(
        bool, "passthru", 1, // Can jump up or sideways through the platform.
        bool, "bouncy",   1,
        bool, "crumble",  1, // Will start crumbling when next landed on.
        bool, "fjord",    1, // This is an ex-platform. Pass through in all
                             // directions.
        uint, "",         4  /* pad to a standard size */));

    // void function(ref Platform, ref Player) interactWithPlayer;
}

enum PlayerState {
    STANDING,
    FALLING,
}

