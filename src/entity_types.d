module entity_types;

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
    HitRect         rect;
    PlatformSpecies species;
    // void function(ref Platform, ref Player) interactWithPlayer;
}

enum PlatformSpecies {
    SOLID,
    PASSTHRU, // Can jump up or sideways through the platform.
    BOUNCY,
    CRUMBLE,  // Will start crumbling when next landed on.
    FJORD,    // This is an ex-platform. Pass through in all directions.
}

enum PlayerState {
    STANDING,
    FALLING,
}

