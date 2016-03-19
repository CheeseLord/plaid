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
    //     if (somePlatform.jumpthru) { doSomething(); }
    mixin(bitfields!(
        bool, "jumpthru",   1, // Can jump up or sideways through the platform.
        bool, "intangible", 1, // Can pass through in all directions.
        bool, "invisible",  1,
        bool, "bouncy",     1,
        bool, "crumble",    1, // Will start crumbling when next landed on.
        uint, "",           3  /* pad to a standard size */));

    // void function(ref Platform, ref Player) interactWithPlayer;
}

enum PlayerState {
    STANDING,
    FALLING,
}

