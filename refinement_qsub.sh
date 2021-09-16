#!/bin/bash
#$ -l h_vmem=4G
#$ -l mem_free=4G
#$ -t 1-214
#$ -l h_rt=24:00:00
#$ -R yes
#$ -V

'''
This script is used a submission pipeline to refine structures after qFit is done (ie you have a multiconformer_model2.pdb
Input: PDB IDs 
Output: Post-qFit refine PDBs
'''

#________________________________________________INPUTS________________________________________________#
PDB_file=/wynton/group/fraser/swankowicz/slr/to_final_refine.txt
base_dir='/wynton/group/fraser/swankowicz/slr/'
export OMP_NUM_THREADS=1

#________________________________________________SET PATHS________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.19.2-4158-intel-linux-2.6-x86_64-centos6/phenix-1.19.2-4158/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit
which python

#________________________________________________RUN REFINEMENT________________________________________________#
PDB=$(cat $PDB_file | head -n $SGE_TASK_ID | tail -n 1)
echo $PDB

if [[ -z "$TMPDIR" ]]; then
  if [[ -d /scratch ]]; then TMPDIR=/scratch/$USER; else TMPDIR=/tmp/$USER; fi
  mkdir -p "$TMPDIR"
  export TMPDIR
fi

cd ${TMPDIR}

cp -R ${base_dir}/${PDB}/ $TMPDIR
cd ${PDB}

mv ${PDB}-sf.mtz ${PDB}.mtz
if [[ -e ${PDB}_qFit.pdb ]]; then
   echo 'Refinement Done'
elif [[ -e multiconformer_model2.pdb ]]; then
   find_ligands.py ${PDB}.pdb ${PDB}
   declare -a lig_names
   FILES=*_ligand.txt
   for f in $FILES
   do
      echo ${f}
      lig_name=$(cat ${f})
      phenix.elbow --chemical_comp=${lig_name} --final=${lig_name}
      lig_names+=(${f})
   done
   qfit_final_refine_xray.sh ${PDB}.mtz multiconformer_model2.pdb
else
   echo 'not ready yet'
fi

cp -R ${TMPDIR}/${PDB}/ ${base_dir}/
