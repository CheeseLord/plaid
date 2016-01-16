module yaml_parser;

import yaml;

import entity_types;
import geometry_types;
import globals;
import platform_functions;


// To parse a struct, the YAML node must be an associative array whose keys
// have exactly the same names as the fields of the struct.
T parseYamlNode(T)(Node node) if (is(T == struct))
{
    enum int NUM_FIELDS = T.tupleof.length;
    T ret;

    // The node must be an associative array (mapping).
    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node is not a mapping.");
    }

    // Iterate over all fields of ret. For each one, parse the corresponding
    // key in the YAML associative array.
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

        // Recursively parse the field, since it could itself be a struct or
        // other compound type.
        field = parseYamlNode!(typeof(field))(child);
    }

    if (node.length > NUM_FIELDS) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node contains unrecognized fields.");
    }

    return ret;
}

T[] parseYamlNode(T: T[])(Node node)
{
    // The node must be a list (sequence).
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
    // The node must be a string.
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

// For any other type, assume it's a primitive and just use node.as to convert
// to the type being requested.
T parseYamlNode(T)(Node node) if (!is(T == struct))
{
    return node.as!T;
}


///////////////////////////////////////////////////////////////////////////////
version (none) {

Velocity parseVelocity(Node node)
{
    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as Velocity: "
                                     "node is not a mapping.");
    }
    if (    !node.containsKey("x") ||   
            !node.containsKey("y")    ) {
        throw new YamlParseException("Cannot parse node as Velocity: "
                                     "node is missing a field.");
    }
    if (node.length > 2) {
        throw new YamlParseException("Cannot parse node as Velocity: "
                                     "node contains an extra field.");
    }

    Velocity ret = {
        x: node["x"].as!double,
        y: node["y"].as!double,
    };
    return ret;
}

HitRect parseHitRect(Node node)
{
    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as HitRect: "
                                     "node is not a mapping.");
    }
    if (    !node.containsKey("x") ||   
            !node.containsKey("y") ||   
            !node.containsKey("w") ||   
            !node.containsKey("h")    ) {
        throw new YamlParseException("Cannot parse node as HitRect: "
                                     "node is missing a field.");
    }
    if (node.length > 4) {
        throw new YamlParseException("Cannot parse node as HitRect: "
                                     "node contains an extra field.");
    }

    HitRect ret = {
        x: node["x"].as!double,
        y: node["y"].as!double,
        w: node["w"].as!double,
        h: node["h"].as!double,
    };
    return ret;
}

ScreenRect parseScreenRect(Node node)
{
    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as ScreenRect: "
                                     "node is not a mapping.");
    }
    if (    !node.containsKey("x") ||   
            !node.containsKey("y") ||   
            !node.containsKey("w") ||   
            !node.containsKey("h")    ) {
        throw new YamlParseException("Cannot parse node as ScreenRect: "
                                     "node is missing a field.");
    }
    if (node.length > 4) {
        throw new YamlParseException("Cannot parse node as ScreenRect: "
                                     "node contains an extra field.");
    }

    ScreenRect ret = {
        x: node["x"].as!int,
        y: node["y"].as!int,
        w: node["w"].as!int,
        h: node["h"].as!int,
    };
    return ret;
}

}
///////////////////////////////////////////////////////////////////////////////



class YamlParseException: Exception {
    // Maybe also take in the problematic node, so we can print it out?
    this(string msg, string file = __FILE__, size_t line = __LINE__,
            Throwable next = null) {
        super(msg, file, line, next);
    }
}


void parseMagic()
{
    // Parse the YAML.
    Node configRoot = Loader("config/magic.yaml").load();
    if (!configRoot.isMapping) {
        // TODO [#13]: Error propagation.
        std.stdio.stderr.writefln("Error: YAML document is not a mapping.");
        return;
    }

    parseYamlMemberTo!(sViewRect)(configRoot, "screen-view");
    parseYamlMemberTo!(wViewRect)(configRoot, "world-view");
    parseYamlMemberTo!(player)   (configRoot, "player");
    parseYamlMemberTo!(platforms)(configRoot, "platforms");
}

// TODO: This could use a better name.
void parseYamlMemberTo(alias parseTo)(Node configRoot, const(char[]) yamlName)
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
