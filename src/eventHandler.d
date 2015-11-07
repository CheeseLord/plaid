module eventHandler;

private import derelict.sdl2.sdl;

private import globals;

void handleEvents()
{
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
        else if (event.type == SDL_KEYDOWN) {
            switch (event.key.keysym.sym) {
                case SDLK_UP:    xVel =    0; yVel = -100; break;
                case SDLK_RIGHT: xVel =  100; yVel =    0; break;
                case SDLK_DOWN:  xVel =    0; yVel =  100; break;
                case SDLK_LEFT:  xVel = -100; yVel =    0; break;
                case SDLK_SPACE: yVel = -100; break;
                default: // Ignore other keys.
            }
        }
    }
}

