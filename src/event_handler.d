module eventHandler;
import std.stdio;

private import std.algorithm;

private import derelict.sdl2.sdl;

private import globals;

private import load_level;

void handleEvents()
{
    // Need to go through all the events so that SDL updates its internal
    // keyboard state array.
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        // Handle the next event here. To get the type of event (keypress,
        // mouse motion, close window, etc.), look at event.type.
        // For a list of possible event types, see
        //     https://wiki.libsdl.org/SDL_EventType
        //
        // If the type is some sort of keypress, you'll want to look at the
        // actual key that was pressed, stored in event.key.keysym. See
        //     https://wiki.libsdl.org/SDL_Keysym
        // for information on interpreting these. That page has links to the
        // lists of key codes and scan codes.
        if (event.type == SDL_QUIT) {
            shouldQuit = true;
        }
    }

    const(ubyte*) keyState = SDL_GetKeyboardState(null);

    if (keyState[SDL_SCANCODE_R]) {
        reloadLevel(currentLevel);
    }

    if      (keyState[SDL_SCANCODE_LEFT] && ! keyState[SDL_SCANCODE_RIGHT]) {
        player.vel.x += -playerWalkAcceleration;
        if (player.vel.x <  -playerMaxWalkSpeed) {
            player.vel.x = -playerMaxWalkSpeed;
        }
    }
    else if (keyState[SDL_SCANCODE_RIGHT] && ! keyState[SDL_SCANCODE_LEFT]) {
        player.vel.x += playerWalkAcceleration;
        if (player.vel.x > playerMaxWalkSpeed) {
            player.vel.x = playerMaxWalkSpeed;
        }
    }
    else {
        if (player.vel.x > 0){
            player.vel.x =  max(player.vel.x - playerWalkAcceleration, 0);
        }
        else if (player.vel.x < 0){
            player.vel.x =  min(player.vel.x + playerWalkAcceleration, 0);
        }
    }
    if (playerState == PlayerState.STANDING) {
        if (keyState[SDL_SCANCODE_UP]) {
            player.vel.y += playerJumpStrength;
        }
    }
}

