#!/bin/bash
#set up a new refinement
#Stephanie Wankowicz 4/5/2019
#git: 01-05-2021

#source Phenix
export PHENIX_OVERWRITE_ALL=true

PDB=$1

echo $PDB
echo $PWD  

  
#get ligand name and list of ligands for harmonic restraints (only used for ensemble refinement)
~/anaconda3/envs/phenix_ens/bin/python /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/PDB_ligand_parser.py $PDB /wynton/home/fraserlab/swankowicz/190419_Phenix_ensemble/ligands_to_remove.csv
lig_name=$(cat "ligand_name.txt")
echo $lig_name

echo '________________________________________________________Starting Phenix cif as mtz________________________________________________________'
phenix.cif_as_mtz $PDB-sf.cif --extend_flags --merge

echo '________________________________________________________Starting Phenix Ready Set________________________________________________________'
phenix.ready_set pdb_file_name=$PDB.pdb

echo '________________________________________________________Checking on FOBS________________________________________________________'
if grep -F _refln.F_meas_au $PDB-sf.cif; then
	echo 'FOBS'
else
        echo 'IOBS'
fi

rm ${PDB}.updated_refine_* #this is in here incase you need to re-run

if [[ -e "${PDB}.ligands.cif" ]]; then
    echo '________________________________________________________Running refinement with ligand.________________________________________________________'
    if grep -F _refln.F_meas_au $PDB-sf.cif; then
        phenix.refine $PDB.updated.pdb $PDB-sf.mtz ${PDB}.ligands.cif /wynton/group/fraser/swankowicz/script/ens_refinement_scripts/phenix_pipeline/finalize.params refinement.input.xray_data.labels="FOBS,SIGFOBS" refinement.input.xray_data.r_free_flags.label=R-free-flags
    else
	 phenix.refine $PDB.updated.pdb $PDB-sf.mtz ${PDB}.ligands.cif /wynton/group/fraser/swankowicz/script/ens_refinement_scripts/phenix_pipeline/finalize.params refinement.input.xray_data.labels="IOBS,SIGIOBS" refinement.input.xray_data.r_free_flags.label=R-free-flags
    fi
  else
    echo '________________________________________________________Running refinement without ligand.________________________________________________________'
    if grep -F _refln.F_meas_au $PDB-sf.cif; then
	phenix.refine $PDB.updated.pdb $PDB-sf.mtz /wynton/group/fraser/swankowicz/script/ens_refinement_scripts/phenix_pipeline/finalize.params refinement.input.xray_data.labels="FOBS,SIGFOBS" refinement.input.xray_data.r_free_flags.label=R-free-flags
    else
	phenix.refine $PDB.updated.pdb $PDB-sf.mtz /wynton/group/fraser/swankowicz/script/ens_refinement_scripts/phenix_pipeline/finalize.params refinement.input.xray_data.labels="IOBS,SIGIOBS" refinement.input.xray_data.r_free_flags.label=R-free-flags
   fi
 fi

