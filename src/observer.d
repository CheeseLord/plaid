module observer;

private import std.stdio;

private import globals;
private import win_lose;


enum NotifyType {
    WIN_LEVEL, LOSE_LEVEL,
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


bool initializeObservers()
{
    observers = new ObserverList();

    // TODO [#33]: Move this somewhere more sensible.
    win_lose.registerObservers();

    return true;
}

