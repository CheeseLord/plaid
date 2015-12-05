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
    // TODO [#3]: Magic numbers bad.
    double GROUND_HEIGHT = 20.0;

    debug(player_pos){
        writefln("x = %0.2f, y = %0.2f", player.rect.left, player.rect.bottom);
    }

    if (player.rect.bottom < GROUND_HEIGHT && player.vel.y <= 0) {
        player.rect.bottom = GROUND_HEIGHT;
        player.vel.y = 0;
    }
    else {
        player.rect.left = player.rect.left + player.vel.x * elapsedSeconds;
        player.rect.bottom = player.rect.bottom + player.vel.y * elapsedSeconds;
    }
}

