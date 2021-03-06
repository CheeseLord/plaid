module observer;

private import std.stdio;


enum NotifyType {
    WIN_LEVEL, LOSE_LEVEL,
    PLAYER_JUMP, PLAYER_LAND, PLAYER_BOUNCE,
    PLATFORM_CRUMBLE,
};


alias Observer = void delegate(NotifyType);


public class ObserverList {
    private Observer[] observers_ = [];

    void addObserver(Observer observer)
    {
        observers_ ~= observer;
    }

    void notify(NotifyType eventInfo)
    {
        foreach (Observer observer; observers_) { observer(eventInfo); }
    }
}

