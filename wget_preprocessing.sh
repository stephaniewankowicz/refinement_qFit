#!/bin/bash


'''
This scipt will allow you to pull down both a PDB and mtz file from the PDB. It will also organize said files into the following folder organization scheme:

base_directory/PDB_ID/:
	PDB.pdb
	PDB-sf.cif

Input: List of PDB ids
Output: Folder populated with PDB, cif 
'''

source /wynton/group/fraser/swankowicz/phenix-installer-1.19.2-4158-intel-linux-2.6-x86_64-centos6/phenix-1.19.2-4158/phenix_env.sh

#________________________________________________INPUTS________________________________________________#
base_folder='/wynton/group/fraser/swankowicz/slr/BCL2' #base folder (where you want to put folders/pdb files

pdb_filelist=/wynton/group/fraser/swankowicz/slr/BCL2/ar_pdb.txt
#cat ${pdb_filelist} | sed -n 1'p' | tr ',' '\n' | while read PDB; do
#  echo $PDB
while read -r line; do
  cd $base_folder
  if [ -d "$line" ]; then
    echo "Folder exists." 
  else
    mkdir $line
    cd $line
    phenix.fetch_pdb ${line}
    phenix.fetch_pdb -x ${line}
  fi
done < $pdb_filelist
  #wget https://files.rcsb.org/download/${PDB}.pdb1
  #wget https://files.rcsb.org/download/${PDB}-sf.cif
  #wget http://edmaps.rcsb.org/coefficients/${PDB}.mtz
#done < $pdb_filelist
