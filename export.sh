EXPORT_NAME=OneMillionMicroscopicKittens

# Find Godot app path
godotapp=$(mdfind "kMDItemKind == 'Application' && kMDItemFSName == 'Godot*' && kMDItemContentTypeTree == 'public.executable'" | head -n 1)
if [ -z "$godotapp" ]; then
    echo "Error: Godot application not found."
    exit 1
fi

# Set the path to the Godot executable
godot="$godotapp/Contents/MacOS/Godot"
echo "Godot app at: $godot"

ALL=(web mac windows linux)

# Check if any arguments are provided
if [ $# -eq 0 ]; then
    # No arguments provided, use the default list
    export_list=("${ALL[@]}")
else
    # Arguments provided, use them as the export list
    export_list=("$@")
fi

# Loop through the export list
for export_type in "${export_list[@]}"; do
    case $export_type in
        web)
            echo "Web export"
            mkdir -v -p build/web
            "$godot" --headless --verbose --export-release "Web" build/web/index.html
            ;;
        mac)
            echo "Mac export"
            mkdir -v -p build/mac
            "$godot" --headless --verbose --export-release "MacOS" build/mac/$EXPORT_NAME.zip
            ;;
        windows)
            echo "Windows export"
            mkdir -v -p build/windows
            "$godot" --headless --verbose --export-release "Windows Desktop" build/windows/$EXPORT_NAME.zip
            ;;
        linux)
            echo "Linux export"
            mkdir -v -p build/linux
            "$godot" --headless --verbose --export-release "Linux" build/linux/$EXPORT_NAME.zip
            ;;
        *)
            echo "Invalid export type: $export_type"
            ;;
    esac
done
