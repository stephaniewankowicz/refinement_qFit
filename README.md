This repository contains the scripts to run refinement on a large group of PDB files, run qFit, and run post qFit refinement.

Due to the large number of PDB files, there are A LOT of issues with refinement. The majority of them should be caught with the original script, however, additional scripts are provided that may solve the special problem you run into.

To run the scripts in this repository, you will need a phenix software installment and a conda enviornment where qFit is activated (see: https://github.com/ExcitedStates/qfit-3.0 for more info).

1) wget_preprocessing.sh: This will pull the PDB and SF-cif files from phenix for you. It will also set up your folders for each PDB. 

2) phenix_setup_SGE.sh: This is the submission script to run pre-qFit refinement, composite omit, and qFit.

3) refinement_qsub.sh: This is the post qFit refinement submission script. 

Other scripts in this folder:

1) phenix_prep.sh: This is called from the phenix_setup_SGE.sh to run refinement. 
