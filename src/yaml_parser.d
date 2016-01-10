module yaml_parser;

import std.meta;

import yaml;

import entity_types;
import geometry_types;
import globals;


T parseYamlNode(T)(Node node)
{
    enum int NUM_FIELDS = T.tupleof.length;
    T ret;

    if (!node.isMapping) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node is not a mapping.");
    }

    foreach (i, ref field; ret.tupleof) {
        if (!node.containsKey(__traits(identifier, ret.tupleof[i]))) {
            throw new YamlParseException("Cannot parse node as " ~
                __traits(identifier, T) ~ ": node has no " ~
                __traits(identifier, ret.tupleof[i]) ~ " field.");
        }

        // FIXME: Recurse.
        field = node[__traits(identifier, ret.tupleof[i])].as!(typeof(field));
    }

    if (node.length > NUM_FIELDS) {
        throw new YamlParseException("Cannot parse node as " ~
            __traits(identifier, T) ~ ": node contains unrecognized fields.");
    }

    return ret;
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
