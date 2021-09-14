#!/bin/bash
#$ -l h_vmem=2G
#$ -l mem_free=2G
#$ -t 1-214
#$ -l h_rt=24:00:00
#$ -R yes
#$ -V
#this script will run qfit based on the input PDB names you have.

#________________________________________________INPUTS________________________________________________#
PDB_file=/wynton/group/fraser/swankowicz/slr/to_final_refine.txt
base_dir='/wynton/group/fraser/swankowicz/slr/'
export OMP_NUM_THREADS=1

#________________________________________________SET PATHS________________________________________________#
source /wynton/group/fraser/swankowicz/phenix-installer-1.19.2-4158-intel-linux-2.6-x86_64-centos6/phenix-1.19.2-4158/phenix_env.sh
export PATH="/wynton/home/fraserlab/swankowicz/anaconda3/bin:$PATH"
source activate qfit #qfit_ligand #qfit3
which python

#________________________________________________RUN QFIT________________________________________________#
#PDB_file=/wynton/group/fraser/swankowicz/script/text_files/comp_omit4.txt  #list of PDB IDs
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
#cd /wynton/group/fraser/swankowicz/slr/${PDB}/ 
if [[ -e ${PDB}_qFit.pdb ]]; then
   echo 'Refinement Done'
   #sh /wynton/group/fraser/swankowicz/script/qfit_refine_final.sh $PDB
elif [[ -e multiconformer_model2.pdb ]]; then
   #cp /wynton/group/fraser/swankowicz/191227_qfit/${PDB}/${PDB}.mtz /wynton/group/fraser/swankowicz/AWS_output_201019/${PDB}/
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
   #rm ${PDB}-sf.cif*
   #phenix.ready_set hydrogens=false pdb_file_name="multiconformer_model2.pdb.f_modified.pdb"
   /wynton/group/fraser/swankowicz/script/post_qfit_refine_poorcif_removeligands.sh ${PDB} 
   #qfit_final_refine_xray.sh ${PDB}.mtz multiconformer_model2.pdb 
else
   echo 'not ready yet'
fi

#if [[ -e ${PDB}_single_conf.pdb ]]; then
#   echo 'Single Conf Refinement Done'
#else
#   sh /wynton/group/fraser/swankowicz/script/qfit_pre_refine_script.sh $PDB
#fi

cp -R ${TMPDIR}/${PDB}/ ${base_dir}/
