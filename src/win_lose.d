module win_lose;

private import std.stdio;

private import globals;
private import load_level;
private import observer;


public void registerObservers()
{
    observers.addObserver((x) => onWinLose(x));
}


private void onWinLose(NotifyType eventInfo)
{
    if (eventInfo == NotifyType.WIN_LEVEL) {
        debug writefln("Won level!");
        currentLevel = "level1";
        initializeLevel(currentLevel);
    }
    else if (eventInfo == NotifyType.LOSE_LEVEL) {
        debug writefln("Lost level!");
        currentLevel = "level0";
        initializeLevel(currentLevel);
    }
}

