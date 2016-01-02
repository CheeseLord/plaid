module units;

// Type used for lengths in the world. Given in "arbitrary units of length"
// (aul). 2^8 aul = player width.
alias world_length   = int;

// Type used for times in the world. Given in "arbitrary units of time" (aut).
// 2^16 aut = 1 second.
alias world_time     = int;

// Type used for velocities in the world. A world_velocity of 1 is equal to
// AUL_PER_AUT aul/aut.
alias world_velocity = int;
world_velocity AUL_PER_AUT = 2^^16;

