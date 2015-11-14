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

    debug(player_pos){
        writefln("x = %0.2f, y = %0.2f", player.rect.x, player.rect.y);
    }

    if (player.rect.y < GROUND_HEIGHT && player.vel.y <= 0) {
        player.rect.y = GROUND_HEIGHT;
        player.vel.y = 0;
    }
    else {
        player.rect.x += player.vel.x * elapsedSeconds;
        player.rect.y += player.vel.y * elapsedSeconds;
    }
}

