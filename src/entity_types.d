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
    PASSTHRU,
    BOUNCY,
}

enum PlayerState {
    STANDING,
    FALLING,
}

