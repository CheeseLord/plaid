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

module sound;

private import std.string: format;
private import std.stdio;
private import util.sound;


/**
 * Manage BGMs and SEs.
 */
public class Sound: util.sound.Sound {
 private static:
    string[] seFileName =
        ["win.wav", "lose.wav",
         "jump.wav", "land.wav", "bounce.wav", "crumble.wav"];
    string[] musicFileName =
        ["background.wav"];
    int[] seChannel =
        [0, 1, 2, 3, 4, 5];
    Music[string] bgm;
    Chunk[string] se;
    bool[string] seMark;
    string[] bgmFileName = [];
    bool _bgmEnabled = true;
    bool _seEnabled = true;

    public static bool load() {
        loadChunks();
        loadMusics();
        return true;
    }

    private static void loadMusics() {
        Music[string] musics;
        foreach(string fileName; musicFileName) {
            Music music = new Music();
            music.load(fileName);
            bgm[fileName] = music;
            bgmFileName ~= fileName;
        }
    }


    private static void loadChunks() {
        int i = 0;
        foreach (string fileName; seFileName) {
            debug writefln("loading %s", fileName);
            Chunk chunk = new Chunk();
            debug writefln("created chunk");
            chunk.load(fileName, seChannel[i]);
            debug writefln("loaded chunk");
            se[fileName] = chunk;
            seMark[fileName] = false;
            i++;
        }
    }

    public static void playBgm(string name) {
        if (!_bgmEnabled)
            return;
        Music.halt();
        if(name in bgm)
                bgm[name].play();
    }

    public static void playBgm() {
        int bgmIdx = 0;
        playBgm(bgmFileName[bgmIdx]);
    }

    public static void fadeBgm() {
        Music.fade();
    }

    public static void haltBgm() {
        Music.halt();
    }

    public static void playSe(string name) {
        if (!_seEnabled)
            return;
        seMark[name] = true;
    }

    public static void playMarkedSes() {
        string[] keys = seMark.keys;
        foreach (string key; keys) {
            if (seMark[key]) {
                se[key].play();
                seMark[key] = false;
            }
        }
    }

    public static void clearMarkedSes() {
        string[] keys = seMark.keys;
        foreach (string key; keys)
            seMark[key] = false;
    }

    public static void bgmEnabled(bool v) {
        _bgmEnabled = v;
    }

    public static void seEnabled(bool v) {
        _seEnabled = v;
    }
}
