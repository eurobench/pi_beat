printf ("current directory: %s\n", pwd())
addpath("beat") %%beat is the folder containing all the functions needed for the BEAT project PI algos
arg_list = argv ();
if nargin != 1
  printf ("ERROR: There should be 1 arg. A . a .csv file containing the platform data\n");
endif

printf ("platform data: %s\n", arg_list{1});


[PL_p EA_p]=posturographic_routine_perturbation(arg_list{1})