module platform_functions;

private import std.stdio;

private import entity_types;


void scream(ref Platform platform, ref Player player)
{
    writefln("Player (%0.2f, %0.2f) intersects platform (%0.2f, %0.2f)", 
        player.rect.left, player.rect.bottom,
        platform.rect.left, platform.rect.bottom);
}

