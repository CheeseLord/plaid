module load_level;

import std.stdio;

import derelict.sdl2.sdl;
import derelict.util.exception;
import yaml;

import globals;
import platform_functions;
import yaml_parser;

// Set up game objects.
bool setupObjects()
{
    currentLevel = "test_1";
    initializeLevel(currentLevel);
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
