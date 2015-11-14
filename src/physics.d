module physics;

private import std.stdio;

private import entity_types;
private import globals;


void applyGravity(ref Player player, double elapsedSeconds)
{
    player.vel.y += GRAVITY * elapsedSeconds;
}


// TODO [#12]: Get rid of this function.
void enforceGround(ref Player player)
{
    writefln("%s", player.rect.y);
    double GROUND_HEIGHT = 20.0;
    double EPSILON = 0.1;
    if (player.rect.y < GROUND_HEIGHT - EPSILON) {
        player.rect.y = GROUND_HEIGHT;
        player.vel.y = 0;
    }
}

