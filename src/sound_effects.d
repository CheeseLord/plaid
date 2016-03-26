module sound_effects;

private import std.stdio;

private import globals;
private import observer;


public void registerObservers()
{
    observers.addObserver((x) => makeSoundEffect(x));
}


private void makeSoundEffect(NotifyType eventInfo)
{
    // TODO [#37]: Actually make sounds.
    if (eventInfo == NotifyType.PLAYER_JUMP) {
        debug writefln("Jump.");
    }
    else if (eventInfo == NotifyType.PLAYER_LAND) {
        debug writefln("Land.");
    }
    else if (eventInfo == NotifyType.PLAYER_BOUNCE) {
        debug writefln("Bounce.");
    }
}

