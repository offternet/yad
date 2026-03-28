#!/bin/bash

clear 
echo "yad gui 10.x+ required"
echo ""
echo "https://github.com/offternet/yad"
echo ""
echo "This is yad IDE Version 1.0h March 28, 2026."
echo "MIT LICENSE 2026 (c) Robert J. Cooper https://LinDnd.com"
echo ""
echo "Your use of this alpha software version is your acceptace of the MIT LICENSE"
echo ""
echo "Loading yad IDE in 10 seconds"
sleep 10

clear

echo "Now Loading yad gui IDE Version 1.0h"
echo ""

yad --html --uri="file:///production/yad/buttons/yad-ide.gif" --width=300 --height=300 --center --no-buttons --timeout=5 --undecorated

#===================================================================
# ADJUSTABLE PRESETS - Base values for 1366x768 reference screen
# Edit these values to fine-tune window positions for your screen
#===================================================================

# Reference screen resolution (your working screen)
REF_WIDTH="1366"
REF_HEIGHT="768"

# Left window (DND Collector) settings - Working values for reference screen
LEFT_WIDTH_BASE="100"        # Width of left window in pixels
LEFT_POSX_BASE="0"           # X position of left window (0 = left edge)
LEFT_POSY_BASE="0"           # Y position of left window (0 = top edge)
LEFT_BOTTOM_MARGIN_BASE="15" # Bottom margin to subtract from screen height

# Right window (Notebook) settings - Working values for reference screen
RIGHT_POSX_BASE="450"        # X position of right window
RIGHT_POSY_BASE="0"          # Y position of right window
RIGHT_WIDTH_OFFSET_BASE="1"  # Subtract this from calculated width
RIGHT_BOTTOM_MARGIN_BASE="30" # Bottom margin to subtract from screen height

# For complete manual adjusting of windows placement and bypass auto-detect calculated adjustments then
# change AUTO_SCALE="false". Auto Screen Detection, posistioning and sizing does not work all the time.

# Enable auto-scaling based on screen resolution: true (true/false) to turn it off: false
AUTO_SCALE="true"

#===================================================================

#===================================================================
# Safe key generator for YAD (16-bit unsigned integer: 0 to 65535)
generate_yad_key() {
    echo $(( RANDOM % 65536 ))
}

# Generate keys for both containers
fkey=$(generate_yad_key)
fkey2=$(generate_yad_key)

# Ensure keys are different
while [ "$fkey2" -eq "$fkey" ]; do
    fkey2=$(generate_yad_key)
done
#=====================================================================

# Get screen dimensions
read WIDTH HEIGHT <<< $(xdpyinfo | grep dimensions | awk '{print $2}' | tr 'x' ' ')

# Function to scale values based on screen resolution
scale_value() {
    local base_value=$1
    local base_dim=$2
    local current_dim=$3
    
    if [ "$AUTO_SCALE" = "true" ] && [ $base_dim -ne 0 ]; then
        echo $(( base_value * current_dim / base_dim ))
    else
        echo $base_value
    fi
}

# Calculate scaled dimensions based on current screen
if [ "$AUTO_SCALE" = "true" ]; then
    # Scale based on width for horizontal values
    LEFT_WIDTH=$(scale_value $LEFT_WIDTH_BASE $REF_WIDTH $WIDTH)
    LEFT_POSX=$(scale_value $LEFT_POSX_BASE $REF_WIDTH $WIDTH)
    RIGHT_POSX=$(scale_value $RIGHT_POSX_BASE $REF_WIDTH $WIDTH)
    RIGHT_WIDTH_OFFSET=$(scale_value $RIGHT_WIDTH_OFFSET_BASE $REF_WIDTH $WIDTH)
    
    # Scale based on height for vertical values
    LEFT_POSY=$(scale_value $LEFT_POSY_BASE $REF_HEIGHT $HEIGHT)
    LEFT_BOTTOM_MARGIN=$(scale_value $LEFT_BOTTOM_MARGIN_BASE $REF_HEIGHT $HEIGHT)
    RIGHT_POSY=$(scale_value $RIGHT_POSY_BASE $REF_HEIGHT $HEIGHT)
    RIGHT_BOTTOM_MARGIN=$(scale_value $RIGHT_BOTTOM_MARGIN_BASE $REF_HEIGHT $HEIGHT)
else
    # Use base values directly
    LEFT_WIDTH=$LEFT_WIDTH_BASE
    LEFT_POSX=$LEFT_POSX_BASE
    LEFT_POSY=$LEFT_POSY_BASE
    LEFT_BOTTOM_MARGIN=$LEFT_BOTTOM_MARGIN_BASE
    RIGHT_POSX=$RIGHT_POSX_BASE
    RIGHT_POSY=$RIGHT_POSY_BASE
    RIGHT_WIDTH_OFFSET=$RIGHT_WIDTH_OFFSET_BASE
    RIGHT_BOTTOM_MARGIN=$RIGHT_BOTTOM_MARGIN_BASE
fi

# Calculate window dimensions with margins
LEFT_HEIGHT=$((HEIGHT - LEFT_BOTTOM_MARGIN))
RIGHT_HEIGHT=$((HEIGHT - RIGHT_BOTTOM_MARGIN))
RIGHT_WIDTH=$((WIDTH - RIGHT_POSX - RIGHT_WIDTH_OFFSET))

# Create DND output stream file
DND_OUTPUT="/tmp/yad_dnd_output_$$"
> "$DND_OUTPUT"

# Temporary file to store accumulated content
TEMP_FILE="/tmp/yadcode01.sh"

# Initialize or clear the temporary file
> "$TEMP_FILE"

# Flag to track if we're in cleanup
CLEANUP_ENABLED=1

# PIDs to track
DND_PID=""
MONITOR_PID=""
VIEWER_PID=""
MAIN_YAD_PID=""
NOTEBOOK_PID=""

# Cleanup function
cleanup() {
    if [ $CLEANUP_ENABLED -eq 1 ]; then
        # Kill the main yad processes
        kill -9 $MAIN_YAD_PID 2>/dev/null
        kill -9 $NOTEBOOK_PID 2>/dev/null
        
        # Kill the background processes
        kill -9 $DND_PID 2>/dev/null
        kill -9 $MONITOR_PID 2>/dev/null
        kill -9 $VIEWER_PID 2>/dev/null
        
        # Kill any remaining yad processes
        pkill -f "yad.*--key=$fkey" 2>/dev/null
        pkill -f "yad2.*--key=$fkey2" 2>/dev/null
        killall yad yad2 2>/dev/null
        
        # Clean up temp files
        rm -f "$TEMP_FILE" "$DND_OUTPUT" 2>/dev/null
    fi
}
export -f cleanup

#===================================================================
# Function to close the application
close_question() {
    # Disable cleanup temporarily
    CLEANUP_ENABLED=0
    
    yad --question \
        --title="Exit" \
        --center \
        --text="Do you want to exit The LinDnD yad gui Integrated System?" \
        --button="Cancel:1" \
        --button="Exit:0"
    
    if [ $? -eq 0 ]; then
        # Re-enable cleanup and then clean up
        CLEANUP_ENABLED=1
        cleanup
        clear
        exit 0
    else
        # Re-enable cleanup but don't exit
        CLEANUP_ENABLED=1
    fi
}
export -f close_question

trap 'CLEANUP_ENABLED=1; cleanup; exit 0' INT TERM QUIT


#===============================================================================
# LEFT SIDE: DND File Collector (plugs into paned tabnum=1)
#===============================================================================

# Target directory for saved files
TARGET_DIR="/production/yad/scripts"

# Base directory for YAD files
YAD_BASE_DIR="/production/yad"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR" 2>/dev/null

# Counter for successful drops
SUCCESS_COUNT=0

# Function to test run current build
run_yadcode01 () {
    chmod +x /tmp/yadcode01.sh
    bash /tmp/yadcode01.sh
}
export -f run_yadcode01

# Function to extract file path from DND input
extract_file_path() {
    local input="$1"
    local extracted_path=""
    
    if [[ "$input" =~ file://(/[^[:space:]]+) ]]; then
        extracted_path="${BASH_REMATCH[1]}"
        extracted_path=$(printf '%b' "${extracted_path//%/\\x}")
        echo "$extracted_path"
        return 0
    fi
    
    if [[ "$input" == /production/yad* ]]; then
        echo "$input"
        return 0
    fi
    
    if [[ "$input" == file://* ]]; then
        extracted_path="${input#file://}"
        echo "$extracted_path"
        return 0
    fi
    
    return 1
}

# Function to find corresponding .yad file
find_yad_file() {
    local original_path="$1"
    local dirname=$(dirname "$original_path")
    local basename=$(basename "$original_path")
    local name_without_ext="${basename%.*}"
    local yad_file=""
    
    yad_file="${dirname}/${name_without_ext}.yad"
    if [ -f "$yad_file" ] && [ -r "$yad_file" ]; then
        echo "$yad_file"
        return 0
    fi
    
    yad_file="${YAD_BASE_DIR}/${name_without_ext}.yad"
    if [ -f "$yad_file" ] && [ -r "$yad_file" ]; then
        echo "$yad_file"
        return 0
    fi
    
    return 1
}

# Function to validate .yad file
validate_yad_file() {
    local filepath="$1"
    
    if [[ -z "$filepath" ]]; then return 1; fi
    if [ ! -f "$filepath" ]; then return 1; fi
    if [ ! -r "$filepath" ]; then return 1; fi
    if [[ ! "$filepath" == *.yad ]]; then return 1; fi
    
    local mime_type=$(file --mime-type -b "$filepath" 2>/dev/null)
    if [[ ! "$mime_type" == text/* ]]; then return 1; fi
    
    return 0
}

# Function to show error dialog
show_error() {
    local message="$1"
    local preview="$2"
    
    yad --error \
        --title="Invalid Input" \
        --center \
        --text="$message\n\nFirst 100 characters:\n$preview" \
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
        --text="❌ Cannot process file: $(basename "$original_file")\n\nLooking for:\n📄 $expected_yad" \
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
        --text="❌ Cannot process file: $(basename "$filepath")\n\nExtension: ${filepath##*.}\nMIME: $mime_type" \
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
    
    file_path=$(extract_file_path "$dropped")
    
    if [ -n "$file_path" ]; then
        if [[ "$file_path" == *.yad ]]; then
            if validate_yad_file "$file_path"; then
                if cat "$file_path" 2>/dev/null >> "$TEMP_FILE"; then
                    ((SUCCESS_COUNT++))
                    return 0
                else
                    show_error "Failed to read: $file_path" "$preview"
                    return 1
                fi
            else
                local mime_type=$(file --mime-type -b "$file_path" 2>/dev/null)
                show_file_type_error "$file_path" "$mime_type"
                return 1
            fi
        else
            yad_file=$(find_yad_file "$file_path")
            
            if [ -n "$yad_file" ] && [ -f "$yad_file" ]; then
                if validate_yad_file "$yad_file"; then
                    if cat "$yad_file" 2>/dev/null >> "$TEMP_FILE"; then
                        ((SUCCESS_COUNT++))
                        return 0
                    else
                        show_error "Failed to read: $yad_file" "$preview"
                        return 1
                    fi
                else
                    local mime_type=$(file --mime-type -b "$yad_file" 2>/dev/null)
                    show_file_type_error "$yad_file" "$mime_type"
                    return 1
                fi
            else
                local expected_yad="${file_path%.*}.yad"
                show_missing_yad_error "$file_path" "$expected_yad"
                return 1
            fi
        fi
    else
        show_error "Could not extract file path." "$preview"
        return 1
    fi
}

export -f process_drop
export TEMP_FILE
export DND_OUTPUT
export SUCCESS_COUNT

## Function to clear temporary file content
clear_temp_file() {
    if [ -s "$TEMP_FILE" ]; then
        local line_count=$(wc -l < "$TEMP_FILE")
        yad --question \
            --center \
            --title="Clear Content" \
            --text="Clear temporary file?\n\n📊 Lines: $line_count\n✓ Files: $SUCCESS_COUNT" \
            --button="Cancel:1" \
            --button="Clear:0" \
            --width=450
        
        if [ $? -eq 0 ]; then
            # Create a temporary marker file to force update
            local marker_file="/tmp/yad_marker_$$"
            
            # Add blank spaces with unique markers to force scrolling effect
            for i in {1..150}; do
                echo "                                                                                                    [clear_$i]" >> "$TEMP_FILE"
            done
            
            # Create marker to force update in monitoring loop
            echo "System has been cleared. Start New DnD Coding" >> "$TEMP_FILE" 
            
            # Delay to let the flood appear
            sleep 0.8
            
            # Clear the file
            > "$TEMP_FILE"
            SUCCESS_COUNT=0
            export SUCCESS_COUNT
            
            # Write a small marker to ensure the empty file triggers an update
            # This forces the monitoring loop to detect the change
            echo "" >> "$TEMP_FILE"
            
            yad --info \
                --title="Cleared" \
                --center \
                --text="✅ Temporary file cleared!" \
                --timeout=2 \
                --width=300 \
                --no-buttons &
        fi
    else
        yad --info \
            --title="Empty" \
            --center \
            --text="File already empty." \
            --timeout=2 \
            --width=300 \
            --no-buttons
    fi
}
export -f clear_temp_file

# Function to open temporary file in YAD text-info editor
open_in_yad_editor() {
    if [ -s "$TEMP_FILE" ]; then
        local edited_content=$(yad --text-info \
            --center \
            --title="Edit Collected Code" \
            --text="Files: $SUCCESS_COUNT | Lines: $(wc -l < "$TEMP_FILE")" \
            --filename="$TEMP_FILE" \
            --width=800 \
            --height=600 \
            --editable \
            --fontname="Monospace 10" \
            --button="Cancel:1" \
            --button="Save:0")
        
        if [ $? -eq 0 ] && [ -n "$edited_content" ]; then
            echo "$edited_content" > "$TEMP_FILE"
            SUCCESS_COUNT=$(grep -c "^# --- Start of file:" "$TEMP_FILE")
            export SUCCESS_COUNT
            
            yad --info --title="Saved" --text="Changes saved." --timeout=2 --width=300 --no-buttons &
        fi
    else
        yad --warning --title="Empty" --text="No content to edit." --width=300
    fi
}
export -f open_in_yad_editor

# Function to save content to target directory
save_to_target() {
    if [ -s "$TEMP_FILE" ]; then
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        DEFAULT_FILENAME="collected_code_${TIMESTAMP}.sh"
        SAVE_PATH="${TARGET_DIR}/${DEFAULT_FILENAME}"
        
        saved_file=$(yad --file \
            --title="Save Collected Code" \
            --center \
            --filename="$SAVE_PATH" \
            --save \
            --confirm-overwrite \
            --file-filter="Shell Scripts (*.sh) | *.sh" \
            --print)
        
        if [ -n "$saved_file" ] && [ "$saved_file" != "0" ]; then
            cp "$TEMP_FILE" "$saved_file"
            chmod +x "$saved_file" 2>/dev/null
            
            yad --info \
                --title="Saved" \
                --center \
                --text="✅ Saved to:\n$saved_file" \
                --timeout=3 \
                --width=400  \
                --no-buttons &
        fi
    else
        yad --warning --title="Empty" --text="No content to save!" --width=300
    fi
}
export -f save_to_target

#===============================================================================
# DND INPUT STREAM: Capture drops and feed to text-info
#===============================================================================

# Start YAD with DND, capturing output
yad --dnd --plug="$fkey2" --tabnum=1 --print-dnd > "$DND_OUTPUT" &
DND_PID=$!

# Background process to process drops
(
    while kill -0 $DND_PID 2>/dev/null && kill -0 $$ 2>/dev/null; do
        if [ -s "$DND_OUTPUT" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && process_drop "$line"
            done < "$DND_OUTPUT"
            > "$DND_OUTPUT"
        fi
        sleep 0.5
    done
) &
MONITOR_PID=$!

# Text-info viewer that monitors file changes by checking content
(
    # Store the last content to compare
    last_content=""
    
    while kill -0 $$ 2>/dev/null; do
        if [ -f "$TEMP_FILE" ]; then
            current_content=$(cat "$TEMP_FILE" 2>/dev/null)
            if [ "$current_content" != "$last_content" ]; then
                echo "$current_content"
                last_content="$current_content"
            fi
        fi
        sleep 1
    done
) | yad \
    --plug="$fkey2" \
    --tabnum=2 \
    --text-info \
    --tail \
    --fontname="Monospace 10" \
    --editable &
VIEWER_PID=$!

quit_yad () {
    yad --question --title="Exit" --center --text="Do you want to exit?" --button="Cancel:1" --button="Exit:0" 
    
    if [ $? -eq 0 ]; then
        CLEANUP_ENABLED=1
        cleanup
        exit 0
    fi
}
export -f quit_yad

#===============================================================================
# MAIN PANED CONTAINER - Left window with adjustable presets
#===============================================================================

yad \
    --title="YAD DND Input - Smart File Collector" \
    --paned \
    --key="$fkey2" \
    --splitter=150 \
    --text=" <b>CLICK THIS BOX ONCE, Then Drop yad snippets here</b>" \
    --undecorated \
    --width=$LEFT_WIDTH \
    --height=$LEFT_HEIGHT \
    --posx=$LEFT_POSX \
    --posy=$LEFT_POSY \
    --no-buttons &
    
MAIN_YAD_PID=$!

#===============================================================================
# RIGHT SIDE: Notebook Container - Right window with adjustable presets
#===============================================================================


# Debug output
echo "========================================="
echo "Screen Resolution: ${WIDTH}x${HEIGHT}"
echo "Auto-Scale: $AUTO_SCALE"
if [ "$AUTO_SCALE" = "true" ]; then
    echo "Reference Screen: ${REF_WIDTH}x${REF_HEIGHT}"
fi
echo ""
echo "Left Window (DND Collector):"
echo "  Width: $LEFT_WIDTH"
echo "  Height: $LEFT_HEIGHT"
echo "  Position: ${LEFT_POSX},${LEFT_POSY}"
echo "  Bottom Margin: $LEFT_BOTTOM_MARGIN"
echo ""
echo "Right Window (Notebook):"
echo "  Width: $RIGHT_WIDTH"
echo "  Height: $RIGHT_HEIGHT"
echo "  Position: ${RIGHT_POSX},${RIGHT_POSY}"
echo "  Width Offset: $RIGHT_WIDTH_OFFSET"
echo "  Bottom Margin: $RIGHT_BOTTOM_MARGIN"
echo "========================================="

# Launch the notebook container with its plug children
yad2 --plug=$fkey --tabnum=1 --html --uri="file:///production/yad/yad-ide.html" &
yad2 --plug=$fkey --tabnum=2 --field="Field 1":TXT "" &
yad2 --plug=$fkey --tabnum=3 --field="Field 3":TXT "" &
yad2 --plug=$fkey --tabnum=4 --field="Field 4":TXT "" &
yad2 --plug=$fkey --tabnum=5 --field="Field 5":TXT "" &
yad2 --plug=$fkey --tabnum=6 --field="Field 6":TXT "" &
yad2 --plug=$fkey --tabnum=7 --field="Field 7":TXT "" &
yad2 --plug=$fkey --tabnum=8 --field="Field 8":TXT "" &
yad2 --plug=$fkey --tabnum=9 --field="Field 9":TXT "" &
yad2 --plug=$fkey --tabnum=10 --field="Field 10":TXT "" &
yad2 --plug=$fkey --tabnum=11 --field="Field 11":TXT "" &
yad2 --plug=$fkey --tabnum=12 --field="Field 12":TXT "" &

# The notebook container - using geometry with adjustable presets
yad2 --notebook --key="$fkey" \
    --tab="Main" --tab="General" --tab="dnd" --tab="form" --tab="html" \
    --tab="icons" --tab="list" --tab="notebook" --tab="paned" --tab="picture" \
    --tab="print" --tab="progress" \
    --title="LinDnD - yad Integrated Development Environment Framework - bash + yad Gui 13" \
    --geometry=${RIGHT_WIDTH}x${RIGHT_HEIGHT}+${RIGHT_POSX}+${RIGHT_POSY} \
    --buttons-layout=start \
    --button="QUIT:bash -c 'quit_yad'" \
    --button="Clear:bash -c 'clear_temp_file'" \
    --button="Edit:bash -c 'open_in_yad_editor'" \
    --button="Run:bash -c 'run_yadcode01'" \
    --button="Save:bash -c 'save_to_target'" &
    
NOTEBOOK_PID=$!

# Wait for the main yad process to finish
wait $MAIN_YAD_PID

# Clean up on exit
CLEANUP_ENABLED=1
cleanup
exit 0
