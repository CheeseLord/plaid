/* This file was originally provided under the following license:

Copyright 2006 Kenta Cho. All rights reserved.

Redistribution and use in source and binary forms,
with or without modification, are permitted provided that
the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

module util.sound;

private import derelict.sdl2.sdl;
private import derelict.sdl2.mixer;
private import std.string;
private import std.stdio;


/**
 * Initialize and close SDL_mixer.
 */
public class Sound {
 public:
    static bool noSound = false;
    static int bgmVol = 100;
    static int seVol = 100;
 private:

    public static void init() {
        if (noSound)
            return;

        //derelict specific
        DerelictSDL2Mixer.load();

        int audio_rate;
        Uint16 audio_format;
        int audio_channels;
        int audio_buffers;
        if (SDL_InitSubSystem(SDL_INIT_AUDIO) < 0) {
            noSound = true;
            throw new Exception
                ("Unable to initialize SDL_AUDIO");
        }
        audio_rate = 44100;
        audio_format = AUDIO_S16;
        audio_channels = 1;
        audio_buffers = 4096;
        if (Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers) < 0) {
            noSound = true;
            throw new Exception
                ("Couldn't open audio");
        }
        Mix_QuerySpec(&audio_rate, &audio_format, &audio_channels);
        Mix_VolumeMusic(bgmVol);
        Mix_Volume(-1, seVol);
    }

    public static void close() {
        if (noSound)
            return;
        if (Mix_PlayingMusic())
            Mix_HaltMusic();
        Mix_CloseAudio();
    }
}

/**
 * Music.
 */
public class Music {
 public:
    static int fadeOutSpeed = 1280;
    static string dir = "resources/sound";
 private:
    Mix_Music* music;

    public void load(string name) {
        if (Sound.noSound)
            return;
        string fileName = dir ~ "/" ~ name;
        music = Mix_LoadMUS(toStringz(fileName));
        if (!music) {
            Sound.noSound = true;
            throw new Exception("Couldn't load: " ~ fileName);
        }
    }

    public void free() {
        if (music) {
            halt();
            Mix_FreeMusic(music);
        }
    }

    public void play() {
        if (Sound.noSound)
            return;
        Mix_PlayMusic(music, -1);
    }

    public void playOnce() {
        if (Sound.noSound)
            return;
        Mix_PlayMusic(music, 1);
    }

    public static void fade() {
        if (Sound.noSound)
            return;
        Mix_FadeOutMusic(fadeOutSpeed);
    }

    public static void halt() {
        if (Sound.noSound)
            return;
        if (Mix_PlayingMusic())
            Mix_HaltMusic();
    }
}

/**
 * Sound chunk.
 */
public class Chunk {
  public:
    static string dir = "resources/sound";
  private:
    Mix_Chunk* chunk;
    int chunkChannel;

    public void load(string name, int ch) {
        if (Sound.noSound)
            return;
        string fileName = dir ~ "/" ~ name;
        debug writefln("loading %s", fileName);
        chunk = Mix_LoadWAV(toStringz(fileName));
        debug writefln("loaded_file");
        if (!chunk) {
            debug writefln("could not load");
            Sound.noSound = true;
            throw new Exception("Couldn't load: " ~ fileName);
        }
        chunkChannel = ch;
    }

    public void free() {
        if (chunk) {
            halt();
            Mix_FreeChunk(chunk);
        }
    }

    public void play() {
        if (Sound.noSound)
            return;
        Mix_PlayChannel(chunkChannel, chunk, 0);
    }

    public void halt() {
        if (Sound.noSound)
            return;
        Mix_HaltChannel(chunkChannel);
    }
}
