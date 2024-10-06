#!/bin/bash
set -e

godot="godot"
# Find Godot app path
if [[ $(uname) == "Darwin" ]]; then
    godotapp=$(mdfind "kMDItemKind == 'Application' && kMDItemFSName == 'Godot*' && kMDItemContentTypeTree == 'public.executable'" | head -n 1)
    godot="$godotapp/Contents/MacOS/Godot"

    echo "You need to close GoDot before running this script. I will kill it with force for you if it won't die peacefully."
    read -p "Press enter when you have tried to save your work and ask it nicely to close."

    killall -9 Godot 2> /dev/null || true
    sleep 2
fi
if [ -z "$godot" ]; then
    echo "Error: Godot not found."
    exit 1
fi
echo "Godot found at: $godot"


# Find all .bsp files and store them in an array
bsp_files=($(find . -name "*.bsp"))

echo "Deleting: $bsp_files"
rm assets/maps/*.bsp* 2> /dev/null || true

# Loop through the same files and run git checkout to restore them
for file in "${bsp_files[@]}"; do
    echo "Restoring and importing $file"
    git checkout -- "$file"
    "$godot" --headless --import
done

if [[ $(uname) == "Darwin" ]]; then
    open project.godot
fi
echo "Done!"