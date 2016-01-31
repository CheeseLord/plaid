module graphics;

import derelict.sdl2.sdl;

import geometry;
import geometry_types;
import globals;

void renderGame(SDL_Surface *surface)
{
    ScreenRect sPlayerRect = worldToScreenRect(player.rect);
    ScreenRect sPlatformRect;

    SDL_FillRect(surface, null, SDL_MapRGB(surface.format, 255, 255, 255));
    foreach (platform; platforms) {
        sPlatformRect = worldToScreenRect(platform.rect);
        SDL_FillRect(surface, &sPlatformRect,
                     SDL_MapRGB(surface.format, 127, 0, 0));
    }
    SDL_BlitSurface(playerSprite, null, surface, &sPlayerRect);
}
