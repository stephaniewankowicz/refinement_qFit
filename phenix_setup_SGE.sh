#!/bin/bash
#$ -l h_vmem=4G
#$ -l mem_free=4G
#$ -t 1-10
#$ -l h_rt=10:00:00
#$ -pe smp 1
#$ -R yes
#$ -V

'''
This is the submission script for pre-qFit refinement. In the folders to run this script you should have the PDB and the mtz files.
Input: List of PDB IDs
Output: Refined PDB 
'''

#________________________________________________INPUTS________________________________________________#
input_file=/wynton/group/fraser/swankowicz/ultra_high_res/ultra_high_res_names_initial.txt #list of PDB IDs
base_dir='/wynton/group/fraser/swankowicz/ultra_high_res/' #location of folders with PDB
export OMP_NUM_THREADS=1

#________________________________________________Activate Env________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.19.2-4158-intel-linux-2.6-x86_64-centos6/phenix-1.19.2-4158/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit #conda env with qFit activated in it
which python

#________________________________________________RUN PHENIX________________________________________________#
PDB=$(cat $input_file | head -n $SGE_TASK_ID | tail -n 1)
echo $PDB
cd $base_dir
cd ${PDB}

#____________________________________________MOVING TO SCRATCH_____________________________________________#
if [[ -z "$TMPDIR" ]]; then
  if [[ -d /scratch ]]; then TMPDIR=/scratch/$USER; else TMPDIR=/tmp/$USER; fi
  mkdir -p "$TMPDIR"
  export TMPDIR
fi

cd ${TMPDIR}

cp -R ${base_dir}/${PDB}/ $TMPDIR
cd $PDB

sh phenix_prep.sh $PDB

cp -R ${TMPDIR}/$PDB/ $base_dir/ #move back from TMP to basedir
