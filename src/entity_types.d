module entity_types;

private import geometry_types;
public  import geometry_types: WorldPoint;
private import units;

alias HitRect = WorldRect;

struct Velocity {
    world_velocity x;
    world_velocity y;
}

struct Player {
    HitRect  rect;
    Velocity vel;
}

struct Platform {
    HitRect rect;
    void function(ref Platform, ref Player) interactWithPlayer;
}

