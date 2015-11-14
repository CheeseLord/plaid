module physics;

private import std.stdio;

private import entity_types;
private import globals;


void applyGravity(ref Player player, double elapsedSeconds)
{
    player.vel.y += GRAVITY * elapsedSeconds;
}


void updatePosition(ref Player player, double elapsedSeconds)
{
    double GROUND_HEIGHT = 20.0;

    writefln("%s", player.rect.y);

    if (player.rect.y < GROUND_HEIGHT && player.vel.y <= 0) {
        player.rect.y = GROUND_HEIGHT;
        player.vel.y = 0;
    }
    else {
        player.rect.x += player.vel.x * elapsedSeconds;
        player.rect.y += player.vel.y * elapsedSeconds;
    }
}

