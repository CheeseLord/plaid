module eventHandler;

private import derelict.sdl2.sdl;

private import globals;

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

    // TODO [#3]: Magic numbers bad
    if      (keyState[SDL_SCANCODE_LEFT]) {
        player.vel.x = -30;
    }
    else if (keyState[SDL_SCANCODE_RIGHT]) {
        player.vel.x =  30;
    }
    else {
        player.vel.x =   0;
    }

    // TODO [#20] Prevent jumping if the player is in mid-air.
    if (keyState[SDL_SCANCODE_UP]) {
        player.vel.y = 50;
    }
}

