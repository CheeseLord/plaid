module load_level;

private import std.stdio;

private import derelict.sdl2.sdl;
private import derelict.util.exception;
private import yaml;
private import sound;

private import globals;
private import platform_functions;
private import yaml_parser;

// Set up game objects.
bool setupObjects()
{
    currentLevel = "level0";
    initializeLevel(currentLevel);
    Sound.playBgm();
    return true;
}

void reloadLevel(string levelName)
{
    initializeLevel(levelName);
}

// Clean up game objects.
bool cleanupObjects()
{
    // Nothing to do right now.
    return true;
}

void initializeLevel(string levelName)
{
    parseLevel(levelName);
}
