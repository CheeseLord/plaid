module yaml_parser;

import std.conv;
import std.traits;

import yaml;

import entity_types;
import geometry_types;
import globals;


// Parse a YAML associative array.
T parseYamlNode(T)(Node node) if (is(T == struct))
{
    enum int NUM_FIELDS = T.tupleof.length;
    T ret;

    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node is not a mapping.");
    }

    // Iterate over all fields of ret. The YAML node's keys should have exactly
    // the same names as those fields.
    foreach (i, ref field; ret.tupleof) {
        if (!node.containsKey(__traits(identifier, ret.tupleof[i]))) {
            throw new YamlParseException("Cannot parse node as " ~
                __traits(identifier, T) ~ ": node has no " ~
                __traits(identifier, ret.tupleof[i]) ~ " field.");
        }

        // Get the value associated with the key whose name is the same as the
        // name of this field. For example, if we're parsing ret.x, then we
        // parse it from node["x"].
        //
        // Note: We need to use __traits(identifier, ret.tupleof[i]) rather
        // than __traits(identifier, field) because the latter is just "field".
        Node child = node[__traits(identifier, ret.tupleof[i])];

        field = parseYamlNode!(typeof(field))(child);
    }

    if (node.length > NUM_FIELDS) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node contains unrecognized fields.");
    }

    return ret;
}

// Parse a YAML list.
T[] parseYamlNode(T: T[])(Node node)
{
    if (!node.isSequence) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ "[]: node is not a sequence.");
    }

    T[] ret;

    foreach (Node child; node) {
        ret ~= parseYamlNode!T(child);
    }

    return ret;
}

// Parse an enum.
T parseYamlNode(T)(Node node) if (is(T == enum))
{
    string val = node.as!string;

    foreach (member; EnumMembers!T) {
        string memberName = to!string(member);
        if (val == memberName) {
            return member;
        }
    }

    throw new YamlParseException("Cannot parse node as " ~
        __traits(identifier, T) ~ ": no such enum member '" ~ val ~ "'.");
}

// Special case for platforms, since they're modeled differently in the yaml
// and the code.
T parseYamlNode(T : Platform)(Node node)
{
    enum PlatformSpecies {
        JUMPTHRU,
        INTANGIBLE,
        INVISIBLE,
        BOUNCY,
        CRUMBLE,
    }

    struct ParsedPlatform {
        HitRect           rect;
        PlatformSpecies[] species;
    }

    ParsedPlatform intermediate = parseYamlNode!ParsedPlatform(node);

    Platform ret = {
        rect: intermediate.rect,
    };
    foreach (PlatformSpecies species; intermediate.species) {
        switch(species) {
            case PlatformSpecies.JUMPTHRU:   ret.jumpthru   = true; break;
            case PlatformSpecies.INTANGIBLE: ret.intangible = true; break;
            case PlatformSpecies.INVISIBLE:  ret.invisible  = true; break;
            case PlatformSpecies.BOUNCY:     ret.bouncy     = true; break;
            case PlatformSpecies.CRUMBLE:    ret.crumble    = true; break;
            default:
                // The parse should already have failed before we get here.
                assert(false);
        }
    }

    return ret;
}

// For any other type, assume it's a primitive.
T parseYamlNode(T)(Node node) if (!is(T == struct) && !is(T == enum))
{
    return node.as!T;
}

class YamlParseException: Exception {
    // TODO [#13]: Maybe also take in the problematic node, so we can print it
    // out?
    this(string msg, string file = __FILE__, size_t line = __LINE__,
            Throwable next = null) {
        super(msg, file, line, next);
    }
}


void parseMagic()
{
    // TODO [#13]: If the file doesn't exist, give a graceful error message.
    Node configRoot = Loader("resources/config.yaml").load();
    if (!configRoot.isMapping) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }

    parseYamlTo!(sViewRect)                 (configRoot, "screen-view");
    parseYamlTo!(gravity)                   (configRoot, "gravity");
    parseYamlTo!(playerMaxWalkSpeed)        (configRoot, "max-walk-speed");
    parseYamlTo!(playerWalkAcceleration)    (configRoot, "walk-acceleration");
    parseYamlTo!(playerJumpStrength)        (configRoot, "jump-strength");
}


void parseLevel(string levelName)
{
    Node configRoot = Loader("resources/levels/" ~ levelName ~ ".yaml").load();
    if (!configRoot.isMapping) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }
    parseYamlTo!(wViewRect)      (configRoot, "world-view");
    parseYamlTo!(player)         (configRoot, "player");
    parseYamlTo!(platforms)      (configRoot, "platforms");
    parseYamlTo!(worldScrollRate)(configRoot, "scroll-speed");

    crumblingPlatforms.length = platforms.length;
    crumbleTimers.length      = platforms.length;
    numCrumblingPlatforms     = 0;
}

void parseYamlTo(alias parseTo)(Node configRoot, const(char[]) yamlName)
{
    if (!configRoot.containsKey(yamlName)) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln(`Error: "%s" not present in YAML file.`,
                                  yamlName);
        return;
    }
    Node nodeToParse = configRoot[yamlName];
    parseTo = parseYamlNode!(typeof(parseTo))(nodeToParse);
}
