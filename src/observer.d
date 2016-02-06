module observer;

private import globals;


alias Observer = void delegate(NotifyType);

enum NotifyType {
    WIN_LEVEL, LOSE_LEVEL,
};

class ObserverList {
    Observer[] observers_ = [];

    void addObserver(Observer observer)
    {
        observers_ ~= observer;
    }

    void notify(NotifyType eventInfo)
    {
        foreach (Observer observer; observers_) { observer(eventInfo); }
    }
}

void initializeObservers()
{
    observers = new ObserverList();
}

