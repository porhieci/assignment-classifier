#!/usr/bin/bash

################################################################
# Remove previous logs
if [[ -e logs ]]; then
    rm logs
fi

################################################################
# USAGE
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 ([--groups] | livrable)"
    exit 1
fi

################################################################
# Generate groups file
if [[ $1 == "--groups" ]]; then
    if [[ -e groups ]]; then
        rm groups
        touch groups
    fi
    
    for folder in *_assignsubmission_file/; do
        student="${folder%%_*}"
        echo "$student " >> groups
    done
    echo "" >> groups
    
    echo "'groups' file created successfully, please assign the students to groups."  
    
    exit 0
fi

################################################################
# Assign groups

declare -A groups

while read line; do
    student="${line% *}"
    key="${student// /_}"
    val="${line##* }"

    groups[$key]="$val"
done < groups

################################################################
# Rename files


for folder in *_assignsubmission_file; do
    student="${folder%%_*}"
    firstname="${student%% *}"
    lastname="${student#* }"
    upper_lastname="${lastname^^}"
    dest_folder="$upper_lastname $firstname"
    
    group="${groups["${student// /_}"]}"
    
    # TODO : if a student doesn't have a group, then remove the folder and everything inside

    # multiple files for one student > do not rename but log
    nb_files=$(ls "${folder// /\ }" 2>> /dev/null | wc -l)
    
    if [ $nb_files -gt 1 ]; then
        echo "Multiple files submitted by $dest_folder." >> logs
    else
        file=$folder/$(ls "${folder// /\ }" 2>> /dev/null)
        ext="${file##*.}"

        # TODO :
        # if [[ext == "zip" || ext == "tar.gz" || ... ]]; do
        #     # unzip the file
        #     # foreach i file extracted from the archive, rename it to $group/"${dest_folder// /\ }"/$1($i).$ext
        mv "${file// /\ }" $group/"${dest_folder// /\ }"/$1.$ext 2>> /dev/null
        rmdir "${folder// /\ }" 2>> /dev/null
    fi
    
done

################################################################
# Display logs

cat logs 2>> /dev/null
