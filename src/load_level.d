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
    // Nothing to do right now.
    initializeLevel("test_0");
    return true;
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
