/*
 * $Id: sound.d,v 1.1.1.1 2006/11/19 07:54:55 kenta Exp $
 *
 * Copyright 2006 Kenta Cho. Some rights reserved.
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
        ["jump.wav", "land.wav"];
    string[] musicFileName =
        ["background.wav"];
    int[] seChannel =
        [0, 1];
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
