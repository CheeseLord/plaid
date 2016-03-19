module globals;

private import derelict.sdl2.sdl;

private import observer;

public import geometry_types;
public import entity_types;

// Constants
immutable int FRAME_RATE = 20;
immutable int MIN_SCREEN_WIDTH  = 80;
immutable int MIN_SCREEN_HEIGHT = 60;

// TODO [#3] Move to yaml.
immutable double CRUMBLE_TIME = 1.0;

double gravity;
double worldScrollRate;

double playerWalkAcceleration;
double playerMaxWalkSpeed;
double playerJumpStrength;

// Game state
Player player;
Platform[] platforms;
PlayerState playerState = PlayerState.FALLING;
string currentLevel;

// Lists of the indices of the platforms that are currently crumbling and the
// times left until they finish crumbling, in no particular order. These arrays
// both have the same length as platforms, but only the elements from 0 to
// numCrumblingPlatforms-1 actually represent crumbling platforms.
size_t[] crumblingPlatforms;
double[] crumbleTimers;
size_t   numCrumblingPlatforms;

ObserverList observers;

// This variable is set to true when it's time to end the program -- perhaps
// because the user tried to close the window, or they clicked an in-game
// "Quit" button.
bool shouldQuit = false;

// Used for converting between world and screen coordinates.
WorldRect  wViewRect;
ScreenRect sViewRect;

