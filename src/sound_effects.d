module sound_effects;

private import std.stdio;

private import globals;
private import observer;
private import sound;


public void registerObservers()
{
    observers.addObserver((x) => makeSoundEffect(x));
}


private void makeSoundEffect(NotifyType eventInfo)
{
    if (eventInfo == NotifyType.PLAYER_JUMP) {
        debug writefln("Jump.");
        Sound.playSe("jump.wav");
        Sound.playMarkedSes();
    }
    else if (eventInfo == NotifyType.PLAYER_LAND) {
        debug writefln("Land.");
        Sound.playSe("land.wav");
        Sound.playMarkedSes();
    }
    else if (eventInfo == NotifyType.PLAYER_BOUNCE) {
        debug writefln("Bounce.");
        Sound.playSe("bounce.wav");
        Sound.playMarkedSes();
    }
}

