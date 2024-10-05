#!/bin/bash
set -e

echo "You need to close GoDot before running this script. I will kill it with force for you if it won't die peacefully."
read -p "Press enter when you have tried to save your work and ask it nicely to close."

killall -9 Godot 2> /dev/null || true

# Find all .bsp files and store them in an array
bsp_files=($(find . -name "*.bsp"))

echo "Deleting all bsp files"
rm assets/maps/*.bsp* 2> /dev/null || true

read -p "Now start GoDot and open the project, then return here and press enter to continue."

# Loop through the same files and run git checkout to restore them
for file in "${bsp_files[@]}"; do
    echo "Restoring $file"
    git checkout -- "$file"
    
    read -p "Switch to GoDot and wait for the import to finish, then come back here and press enter."
done

echo "Done!"