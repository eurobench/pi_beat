#!/usr/bin/octave -qf

printf ("current directory: %s\n", pwd())
addpath("beat/Functions") %%beat is the folder containing all the functions needed for the BEAT project PI algos
addpath("beat/AdditionalFunctions")
arg_list = argv ();
if nargin != 2
  printf ("ERROR: There should be 2 args. A .csv file containing the angles data, a .csv file containing the platform data\n");
endif

printf ("csv file: %s\n", arg_list{1});
printf ("platform data: %s\n", arg_list{2});

pkg load io
pkg load signal

[mROM CoV]=kinematic_routine_walking(arg_list{1}, arg_list{2})