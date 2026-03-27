#!/bin/bash

fkey=$(($RANDOM * $$))
# Get screen dimensions
read WIDTH HEIGHT <<< $(xdpyinfo | grep dimensions | awk '{print $2}' | tr 'x' ' ')

# Set fixed width for right dnd dialog
RIGHT_WIDTH=450

# Calculate left notebook width (remaining space)
LEFT_WIDTH=$((WIDTH - RIGHT_WIDTH))
# Launch notebook dialog (left half)

yad_ide () {
bash /production/yad/yad-ide.sh

}
export -f yad_ide

    yad2 --plug=$fkey --tabnum=1 --html --uri="file:///production/applications.html" &
    yad2 --plug=$fkey --tabnum=2 --html --uri="file:///production/yad/yad-ide.html" &
    yad2 --plug=$fkey --tabnum=3 --field="Field 3":TXT "" &
    yad2 --plug=$fkey --tabnum=4 --field="Field 4":TXT "" &
    yad2 --plug=$fkey --tabnum=5 --field="Field 5":TXT "" &
    yad2 --plug=$fkey --tabnum=6 --field="Field 6":TXT "" &
    yad2 --plug=$fkey --tabnum=7 --field="Field 7":TXT "" &
    yad2 --plug=$fkey --tabnum=8 --field="Field 8":TXT "" &
    yad2 --plug=$fkey --tabnum=9 --field="Field 9":TXT "" &
    yad2 --plug=$fkey --tabnum=10 --field="Field 10":TXT "" &
    yad2 --notebook 	--key="$fkey" \
--tab="Apps" --tab="yad IDE" --tab="Tab 3" --tab="Tab 4" --tab="Tab 5" \
  --tab="Tab 6" --tab="Tab 7" --tab="Tab 8" --tab="Tab 9" --tab="Tab 10" \
    --width=$LEFT_WIDTH --height=$HEIGHT \
    --posx=0 --posy=0 \
--title="yad gui 13 html sourceview standalone" --no-buttons --undecorated &

#===================================================================================

# Launch paned dialog (right half)

# Temporary file to store accumulated content
TEMP_FILE="/tmp/yadcode01.sh"

# Target directory for saved files
TARGET_DIR="/production/yad/scripts"

# Base directory for YAD files
YAD_BASE_DIR="/production/yad"

# Initialize or clear the temporary file
> "$TEMP_FILE"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR" 2>/dev/null

# Create a temporary file for DND output
DND_OUTPUT="/tmp/yad_dnd_output_$$"
> "$DND_OUTPUT"

# Counter for successful drops
SUCCESS_COUNT=0

# Clean up on exit
trap 'rm -f "$DND_OUTPUT"' EXIT

# Function to test run current build
run_yadcode01 () {
cp /tmp/yadcode01.sh /tmp/run_yadcode01.sh
chmod +x /tmp/run_yadcode01.sh
bash /tmp/run_yadcode01.sh

}
export -f run_yadcode01

# Function to extract file path from DND input (handles binary/URI)
extract_file_path() {
    local input="$1"
    local extracted_path=""
    
    # Try to find file:// URI pattern in the input
    # This handles cases where binary data might contain the URI
    if [[ "$input" =~ file://(/[^[:space:]]+) ]]; then
        extracted_path="${BASH_REMATCH[1]}"
        # URL decode the path (convert %20 to spaces, etc.)
        extracted_path=$(printf '%b' "${extracted_path//%/\\x}")
        echo "$extracted_path"
        return 0
    fi
    
    # Check if it's a plain path starting with /production/yad
    if [[ "$input" == /production/yad* ]]; then
        echo "$input"
        return 0
    fi
    
    # Check if it's a file:// URI without binary data
    if [[ "$input" == file://* ]]; then
        extracted_path="${input#file://}"
        echo "$extracted_path"
        return 0
    fi
    
    # If none of the above, return empty (no valid path found)
    return 1
}

# Function to find corresponding .yad file for a given path
# Handles .png, .jpg, .gif, etc. and looks for same basename with .yad extension
find_yad_file() {
    local original_path="$1"
    local dirname=$(dirname "$original_path")
    local basename=$(basename "$original_path")
    local name_without_ext="${basename%.*}"
    local yad_file=""
    
    # Try to find .yad file with the same name in the same directory
    yad_file="${dirname}/${name_without_ext}.yad"
    
    if [ -f "$yad_file" ] && [ -r "$yad_file" ]; then
        echo "$yad_file"
        return 0
    fi
    
    # If not found, try in the base directory (for files without subdirectories)
    yad_file="${YAD_BASE_DIR}/${name_without_ext}.yad"
    
    if [ -f "$yad_file" ] && [ -r "$yad_file" ]; then
        echo "$yad_file"
        return 0
    fi
    
    # No matching .yad file found
    return 1
}

# Function to validate .yad file (checks if it's a readable text file)
validate_yad_file() {
    local filepath="$1"
    
    # Check if file path is valid
    if [[ -z "$filepath" ]]; then
        return 1
    fi
    
    # Check if file exists
    if [ ! -f "$filepath" ]; then
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filepath" ]; then
        return 1
    fi
    
    # Check if it's a .yad file
    if [[ ! "$filepath" == *.yad ]]; then
        return 1
    fi
    
    # Check if file appears to be a text file (not binary)
    local mime_type=$(file --mime-type -b "$filepath" 2>/dev/null)
    if [[ ! "$mime_type" == text/* ]]; then
        return 1
    fi
    
    return 0
}

# Function to show error dialog with preview
show_error() {
    local message="$1"
    local preview="$2"
    
    yad --error \
        --title="Invalid Input" \
        --center \
        --text="$message\n\nFirst 100 characters of input:\n$preview\n\nWhen dragging images (PNG, JPG, etc.), the script looks for a corresponding .yad file with the same name.\n\nExample: she-bang.png -> she-bang.yad" \
        --width=600 \
        --height=350 \
        --button="OK:0" &
}

# Function to show missing .yad file error
show_missing_yad_error() {
    local original_file="$1"
    local expected_yad="$2"
    
    yad --error \
        --title="Missing YAD File" \
        --center \
        --text="❌ Cannot process file: $(basename "$original_file")\n\nThis appears to be an image file (PNG/JPG/etc.) but the corresponding .yad file was not found.\n\nLooking for:\n📄 $expected_yad\n\nPlease ensure that a .yad file with the same name exists in the same directory as the image." \
        --width=550 \
        --height=300 \
        --button="OK:0" &
}

# Function to show file type error
show_file_type_error() {
    local filepath="$1"
    local mime_type="$2"
    
    yad --error \
        --title="Invalid File Type" \
        --center \
        --text="❌ Cannot process file: $(basename "$filepath")\n\nReason: Only .yad text files are accepted.\n\nDetected:\n• File extension: ${filepath##*.}\n• MIME type: $mime_type\n\nIf this is an image file, make sure a .yad file with the same name exists." \
        --width=550 \
        --height=300 \
        --button="OK:0" &
}

# Function to process dropped content
process_drop() {
    local dropped="$1"
    local file_path=""
    local yad_file=""
    local preview="${dropped:0:100}"
    
    echo "DEBUG: Processing drop input (first 100 chars): $preview" >> /tmp/yad_debug.log
    
    # Extract the file path from the dropped content (handles binary/URI)
    file_path=$(extract_file_path "$dropped")
    
    if [ -n "$file_path" ]; then
        echo "DEBUG: Extracted path: $file_path" >> /tmp/yad_debug.log
        
        # Check if this is a .yad file
        if [[ "$file_path" == *.yad ]]; then
            # Direct .yad file drop - validate and process
            if validate_yad_file "$file_path"; then
                # Get file info for logging
                local file_size=$(wc -c < "$file_path")
                local mime_type=$(file --mime-type -b "$file_path")
                
                           
                # Read the complete file content as ASCII text
                if cat "$file_path" 2>/dev/null >> "$TEMP_FILE"; then
                    
                    
                    ((SUCCESS_COUNT++))
                    local lines_added=$(wc -l < "$file_path")
                    echo "✓ Added .yad file ($SUCCESS_COUNT): $file_path ($lines_added lines, $file_size bytes)"
                    return 0
                else
                    show_error "Failed to read file contents:\n$file_path" "$preview"
                    return 1
                fi
            else
                # .yad file validation failed
                local mime_type=$(file --mime-type -b "$file_path" 2>/dev/null)
                show_file_type_error "$file_path" "$mime_type"
                return 1
            fi
        else
            # Not a .yad file - try to find corresponding .yad file (PNG -> YAD mapping)
            echo "DEBUG: Non-yad file detected, looking for corresponding .yad file" >> /tmp/yad_debug.log
            
            yad_file=$(find_yad_file "$file_path")
            
            if [ -n "$yad_file" ] && [ -f "$yad_file" ]; then
                echo "DEBUG: Found corresponding .yad file: $yad_file" >> /tmp/yad_debug.log
                
                # Validate the found .yad file
                if validate_yad_file "$yad_file"; then
                    # Get file info for logging
                    local file_size=$(wc -c < "$yad_file")
                    local mime_type=$(file --mime-type -b "$yad_file")
                    
                                     
                    # Read the complete file content as ASCII text
                    if cat "$yad_file" 2>/dev/null >> "$TEMP_FILE"; then
                       
                        
                        ((SUCCESS_COUNT++))
                        local lines_added=$(wc -l < "$yad_file")
                        echo "✓ Added .yad file ($SUCCESS_COUNT): $yad_file (from image $(basename "$file_path")) ($lines_added lines, $file_size bytes)"
                        return 0
                    else
                        show_error "Failed to read .yad file contents:\n$yad_file" "$preview"
                        return 1
                    fi
                else
                    # Found .yad file but it's invalid (not text, etc.)
                    local mime_type=$(file --mime-type -b "$yad_file" 2>/dev/null)
                    show_file_type_error "$yad_file" "$mime_type"
                    return 1
                fi
            else
                # No corresponding .yad file found
                local expected_yad="${file_path%.*}.yad"
                show_missing_yad_error "$file_path" "$expected_yad"
                return 1
            fi
        fi
    else
        # No valid file path found in the dropped content
        show_error "Could not extract a valid file path from dropped content.\n\nDropped content appears to be binary data or invalid format.\n\nWhen dragging images (PNG, JPG, etc.), the script looks for a corresponding .yad file with the same name." "$preview"
        return 1
    fi
}

export -f process_drop
export TEMP_FILE
export DND_OUTPUT
export SUCCESS_COUNT

# Function to clear temporary file content
clear_temp_file() {
    if [ -s "$TEMP_FILE" ]; then
        # Ask for confirmation before clearing
        local line_count=$(wc -l < "$TEMP_FILE")
        yad --question \
            --center \
            --title="Clear Content" \
            --text="Are you sure you want to clear the temporary file?\n\nCurrent content:\n📊 Lines: $line_count\n✓ Files processed: $SUCCESS_COUNT\n\nThis action cannot be undone!" \
            --button="Cancel:1" \
            --button="Clear:0" \
            --width=450
        
        if [ $? -eq 0 ]; then
            # Clear the temporary file
            > "$TEMP_FILE"
            # Reset success count
            SUCCESS_COUNT=0
            export SUCCESS_COUNT
            
            yad --info \
                --title="Content Cleared" \
                --center \
                --text="✅ Temporary file has been cleared!\n\nFile: $TEMP_FILE\n\nYou can now start adding new content." \
                --timeout=3 \
                --width=400
            
            # Show notification
            yad --notification --text="Temporary file cleared" --center --timeout=2
        fi
    else
        yad --info \
            --title="Already Empty" \
            --center \
            --text="Temporary file is already empty.\n\nFile: $TEMP_FILE\nFiles processed: $SUCCESS_COUNT" \
            --timeout=2 \
            --width=400
    fi
}

export -f clear_temp_file

# Function to open temporary file in YAD text-info editor (NO SAVE TO DIRECTORY)
open_in_yad_editor() {
    if [ -s "$TEMP_FILE" ]; then
        # Open the temporary file in YAD text-info dialog with editing capabilities
        # Use --filename to load the file content
        local edited_content=$(yad --text-info \
            --center \
            --title="Edit Collected Code - $(basename "$TEMP_FILE")" \
            --text="<b>Collected Scripts</b>\n\nFiles processed: $SUCCESS_COUNT\nTotal lines: $(wc -l < "$TEMP_FILE")\n\nYou can edit the content below. Click Save to replace the temporary file content, or Cancel to discard edits.\n\n<b>Note:</b> To save to the target directory, close this editor and use the 'Save to Directory' button in the main window." \
            --filename="$TEMP_FILE" \
            --width=800 \
            --height=600 \
            --editable \
            --fontname="Monospace 10" \
            --button="Cancel:1" \
            --button="Save Changes:0")
        
        if [ $? -eq 0 ] && [ -n "$edited_content" ]; then
            # REPLACE the entire content (not append) by overwriting the file
            echo "$edited_content" > "$TEMP_FILE"
            
            # Recalculate success count based on the new content
            # Count number of "# --- Start of file:" markers to determine file count
            local new_count=$(grep -c "^# --- Start of file:" "$TEMP_FILE")
            SUCCESS_COUNT=$new_count
            export SUCCESS_COUNT
            
            yad --info \
                --title="Changes Saved" \
                --text="Changes have been saved to the temporary file.\n\nFile: $TEMP_FILE\nLines: $(wc -l < "$TEMP_FILE")\nFiles processed: $SUCCESS_COUNT\n\nUse 'Save to Directory' button to save permanently." \
                --timeout=5 \
                --width=500
        fi
    else
        yad --warning \
            --title="Empty File" \
            --center \
            --text="No content to edit.\n\nThe temporary file is empty.\n\nPlease add some valid content first.\n\nFiles processed: $SUCCESS_COUNT" \
            --width=400 \
            --height=150
    fi
}

export -f open_in_yad_editor

# Function to save content to target directory
save_to_target() {
    if [ -s "$TEMP_FILE" ]; then
        # First, optionally edit the content
        local edited_content=$(yad --text-info \
            --title="Review and Edit Before Saving" \
            --center \
            --text="<b>Review and Edit Collected Scripts</b>\n\nFiles processed: $SUCCESS_COUNT\nTotal lines: $(wc -l < "$TEMP_FILE")\n\nEdit the content below, then click Continue to choose a filename and save.\n\n<b>Note:</b> This will save the content to the target directory permanently." \
            --filename="$TEMP_FILE" \
            --width=800 \
            --height=600 \
            --editable \
            --fontname="Monospace 10" \
            --button="Cancel:1" \
            --button="Continue to Save:0")
        
        if [ $? -eq 0 ] && [ -n "$edited_content" ]; then
            # Save the edited content back to temp file (replace, not append)
            echo "$edited_content" > "$TEMP_FILE"
            
            # Recalculate success count based on the edited content
            local new_count=$(grep -c "^# --- Start of file:" "$TEMP_FILE")
            SUCCESS_COUNT=$new_count
            export SUCCESS_COUNT
        elif [ $? -eq 1 ]; then
            # User cancelled
            return
        fi
        
        # Generate a filename based on timestamp
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        DEFAULT_FILENAME="collected_code_${TIMESTAMP}.sh"
        SAVE_PATH="${TARGET_DIR}/${DEFAULT_FILENAME}"
        
        # Let user choose or confirm save location
        saved_file=$(yad --file \
            --title="Save Collected Code to Directory" \
            --center \
            --filename="$SAVE_PATH" \
            --save \
            --confirm-overwrite \
            --file-filter="Shell Scripts (*.sh) | *.sh" \
            --file-filter="All files (*) | *" \
            --print)
        
        if [ -n "$saved_file" ] && [ "$saved_file" != "0" ]; then
            cp "$TEMP_FILE" "$saved_file"
            chmod +x "$saved_file" 2>/dev/null
            
            # Count total lines
            total_lines=$(wc -l < "$TEMP_FILE")
            
            # Show success dialog with option to clear or keep content
            yad --question \
                --title="Save Successful" \
                --center \
                --text="✅ File saved successfully!\n\n📁 Location: $saved_file\n📊 Lines saved: $total_lines\n✓ Files processed: $SUCCESS_COUNT\n\n📂 Target directory: $TARGET_DIR\n\nDo you want to clear the temporary file now?" \
                --button="Keep Content:1" \
                --button="Clear Content:0" \
                --width=500 \
                --height=300
            
            if [ $? -eq 0 ]; then
                # User chose to clear content
                > "$TEMP_FILE"
                SUCCESS_COUNT=0
                export SUCCESS_COUNT
                yad --info \
                    --title="Content Cleared" \
                    --center \
                    --text="Temporary file has been cleared.\n\nYou can now start adding new content." \
                    --timeout=2 \
                    --width=400
            fi
        fi
    else
        yad --warning \
            --text="⚠️ No content to save!\n\nThe temporary file is empty.\n\nPlease drag and drop valid .yad files or images with corresponding .yad files first.\n\nExample:\n• she-bang.yad (direct drop)\n• she-bang.png (looks for she-bang.yad)" \
            --center \
            --title="Warning" \
            --width=550 \
            --height=250
    fi
}

export -f save_to_target

# Function to update dialog text with current count
update_dialog_text() {
    local line_count=$(wc -l < "$TEMP_FILE" 2>/dev/null || echo 0)
    echo "Current lines: $line_count | Files processed: $SUCCESS_COUNT"
}

export -f update_dialog_text

cleanup_and_exit() {
    # Kill yad2 first (child windows)
    killall yad2
    
    # Wait a moment for yad2 to close
    sleep .5
    
    # Kill main yad window
    killall yad
    
    # Exit the script
    exit 0
}


echo "Script completed. Processed $SUCCESS_COUNT file(s)."


close_question () {
  
yad3 --question \
        --title="Unsaved Content" \
        --center \
        --text="Do you want to exit The LinDnD yad gui Intergrated System ?" \
        --button="Cancel:1" \
        --button="Close yad gui IDE:0"
    
    if [ $? -eq 0 ]; then
        killall yad2 2>/dev/null
sleep 1
killall yad 2>/dev/null
    fi

}
export -f close_question


  


# Start YAD with DND, capturing output
yad --dnd \
    --title="YAD DND Input - Smart File Collector" \
    --text="═══════════════════════════════════════════════════\n    SMART FILE COLLECTOR (YAD + Image Mapping)\n═══════════════════════════════════════════════════\n\n📁 Temporary File: $TEMP_FILE\n📊 Current lines: $(wc -l < "$TEMP_FILE" 2>/dev/null || echo 0)\n✓ Files processed: $SUCCESS_COUNT\n📂 Save location: $TARGET_DIR\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n📌 How it works:\n   • Drag .yad files → Read directly\n   • Drag image files (PNG, JPG, etc.) → Look for .yad file with same name\n   \n   Example: she-bang.png → Looks for she-bang.yad\n\n⚠️  Requirements:\n   • .yad files must be valid text files\n   • Image files must have matching .yad file in same directory\n   • All files must be in /production/yad/ or subdirectories\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n🖱️  Drag and drop files from /production/yad/\n\n🔧 Buttons:\n   • Clear - Empty the temporary file content\n   • Edit - Open temporary file in editor\n   • Run - Test run the collected code\n   • Save - Save permanently to target directory\n   • Quit - Exit the application" \
    --button="QUIT":"bash -c 'close_question'" \
    --button="Clear:bash -c 'clear_temp_file'" \
    --button="Edit:bash -c 'open_in_yad_editor'" \
    --button="Run":"bash -c run_yadcode01" \
    --button="Save:bash -c 'save_to_target'" \
    --print-dnd \
    --undecorated \
    --width=$RIGHT_WIDTH --height=$HEIGHT \
    --posx=$LEFT_WIDTH --posy=0  > "$DND_OUTPUT" &

ret=$?

if [[ $ret -eq 1 ]]; then
    cleanup_and_exit
fi

YAD_PID=$!

# Monitor the DND output file
while kill -0 $YAD_PID 2>/dev/null; do
    if [ -s "$DND_OUTPUT" ]; then
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                process_drop "$line"
                # Update the dialog text dynamically (this would require restarting YAD, so we just log)
                echo "Status: $(wc -l < "$TEMP_FILE") lines, $SUCCESS_COUNT files processed"
            fi
        done < "$DND_OUTPUT"
        > "$DND_OUTPUT"  # Clear the file
    fi
    sleep 0.5
done

# Wait for YAD to finish
wait $YAD_PID 2>/dev/null
exit_status=$?

# Check the exit status
if [ $exit_status -eq 0 ]; then
    # SAVE button was pressed (though we renamed it to Save to Directory)
    # This is handled by the save_to_target function
    :
fi

# Final cleanup - keep TEMP_FILE if it has content and we're not exiting normally?
if [ $exit_status -eq 1 ] && [ -s "$TEMP_FILE" ]; then
    # QUIT was pressed but there's content - ask if user wants to save
    yad --question \
        --title="Unsaved Content" \
        --center \
        --text="You have processed $SUCCESS_COUNT file(s) ($(wc -l < "$TEMP_FILE") lines) in the temporary file.\n\nDo you want to save before quitting?" \
        --button="Save and Quit:0" \
        --button="Quit Without Saving:1"
    
    if [ $? -eq 0 ]; then
        # User wants to save - call the save function
        save_to_target
    fi
fi

# Clean up temporary file
rm -f "$TEMP_FILE"
