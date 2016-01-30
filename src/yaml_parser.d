module yaml_parser;

import yaml;

import entity_types;
import geometry_types;
import globals;
import platform_functions;


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

// Special case: for the 'interactWithPlayer' field of a Platform, we can't
// just parse a function from the YAML. So instead, the YAML contains a string,
// and we check it against a table to figure out which function to use.
//
// Note: this will work fine as long as the following statement holds:
//     A YAML node is parsed as type 'void function(ref Platform, ref Player)'
//     if and only if it is a Platform's interactWithPlayer function.
// If we end up needing this solution for two things with the same type, then
// we'll need to do something else. In that case, I think we can move the check
// up a level: instead of having a specialization for the function type, we add
// a special case to the struct parsing code where if we're parsing a Platform
// and this field is named 'interactWithPlayer', then parse it as a string and
// do the table lookup.
T parseYamlNode(T : void function(ref Platform, ref Player))(Node node)
{
    if (!node.isString) {
        throw new YamlParseException("Cannot parse node as Platform collision "
            "callback: node is not a string.");
    }

    immutable T[string] TABLE = [
        "scream": &scream,
    ];

    if ((node.as!string) in TABLE) {
        return TABLE[node.as!string];
    }
    else {
        throw new YamlParseException("Cannot parse node as Platform collision "
            "callback: no such callback '" ~ node.as!string ~ "'.");
    }
}

// For any other type, assume it's a primitive.
T parseYamlNode(T)(Node node) if (!is(T == struct))
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
    Node configRoot = Loader("config/magic.yaml").load();
    if (!configRoot.isMapping) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }

    parseYamlTo!(sViewRect)         (configRoot, "screen-view");
    parseYamlTo!(wViewRect)         (configRoot, "world-view");
    parseYamlTo!(gravity)           (configRoot, "gravity");
    parseYamlTo!(playerWalkSpeed)   (configRoot, "walk-speed");
    parseYamlTo!(playerJumpStrength)(configRoot, "jump-strength");
    parseYamlTo!(worldScrollRate)(configRoot, "scroll-speed");
}


void parseLevel(string levelName)
{
    Node configRoot = Loader("resources/levels/" ~ levelName ~ ".yaml").load();
    if (!configRoot.isMapping) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }
    parseYamlTo!(player)         (configRoot, "player");
    parseYamlTo!(platforms)      (configRoot, "platforms");
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
