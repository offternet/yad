#!/bin/bash

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

# Set fixed width for right dnd dialog
RIGHT_WIDTH=450

# Calculate left notebook width (remaining space)
LEFT_WIDTH=$((WIDTH - RIGHT_WIDTH))

# Create DND output stream file
DND_OUTPUT="/tmp/yad_dnd_output_$$"
> "$DND_OUTPUT"

# Clean up on exit
trap 'rm -f "$DND_OUTPUT" "$TEMP_FILE"' EXIT

#===================================================================
# Function to close the application
close_question() {
    yad --question \
        --title="Exit" \
        --center \
        --text="Do you want to exit The LinDnD yad gui Integrated System?" \
        --button="Cancel:1" \
        --button="Exit:0"
    
    if [ $? -eq 0 ]; then
        # Clean up
        rm -f "$TEMP_FILE" "$DND_OUTPUT" 2>/dev/null
        sleep 0.5
        killall yad2 2>/dev/null
        sleep 0.5
        killall yad 2>/dev/null
        exit 0
    fi
}
export -f close_question
#===================================================================

#===============================================================================
# LEFT SIDE: Notebook Container (plugs into paned tabnum=1)
#===============================================================================

# Launch the notebook container with its plug children
yad2 --plug=$fkey --tabnum=1 --field="Field 1":TXT "" &
yad2 --plug=$fkey --tabnum=2 --html --uri="file:///production/yad/yad-ide.html" &
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
yad2 --plug=$fkey --tabnum=13 --field="Field 13":TXT "" &
yad2 --plug=$fkey --tabnum=14 --field="Field 14":TXT "" &

# The notebook container (this is the actual notebook window)
yad2 --notebook --key="$fkey" \
    --tab="application" --tab="Main" --tab="dnd" --tab="form" --tab="html" \
    --tab="icons" --tab="list" --tab="notebook" --tab="paned" --tab="picture" \
    --tab="print" --tab="progress" --tab="general" --tab="calendar" \
    --title="LinDnD - yad Intergrated Development Environment Framework - bash + yad Gui 13" \
    --width=$LEFT_WIDTH --height=$HEIGHT \
    --posx=0 --posy=0 \
    --no-buttons &

#===============================================================================
# RIGHT SIDE: DND File Collector (plugs into paned tabnum=2)
#===============================================================================

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

# Function to clear temporary file content
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
            # Flood with dots for visual effect
            for i in {1..100}; do
                echo "                                                                                                 " >> "$TEMP_FILE"
            done
            sleep 0.5
            > "$TEMP_FILE"
            SUCCESS_COUNT=0
            export SUCCESS_COUNT
            
            yad --info \
                --title="Cleared" \
                --center \
                --text="✅ Temporary file cleared!" \
                --timeout=2 \
                --width=300 &
        fi
    else
        yad --info \
            --title="Empty" \
            --center \
            --text="File already empty." \
            --timeout=2 \
            --width=300
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
            
            yad --info --title="Saved" --text="Changes saved." --timeout=2 --width=300 &
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
                --width=400 &
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
    while kill -0 $DND_PID 2>/dev/null; do
        if [ -s "$DND_OUTPUT" ]; then
            while IFS= read -r line; do
                [ -n "$line" ] && process_drop "$line"
            done < "$DND_OUTPUT"
            > "$DND_OUTPUT"
        fi
        sleep 0.5
    done
) &

# Text-info viewer that tails TEMP_FILE
tail -f "$TEMP_FILE" 2>/dev/null | yad \
    --plug="$fkey2" \
    --tabnum=2 \
    --text-info \
    --tail \
    --fontname="Monospace 10" \
    --editable &

#===============================================================================
# MAIN PANED CONTAINER - THIS MUST NOT BE BACKGROUNDED
#===============================================================================

# Launch the main paned container (NO & at the end!)
yad \
    --title="YAD DND Input - Smart File Collector" \
    --paned \
    --key="$fkey2" \
    --splitter=250 \
    --text="                   <b>Drop yad snippets here</b>" \
    --button="QUIT":"bash -c 'close_question'" \
    --button="Clear:bash -c 'clear_temp_file'" \
    --button="Edit:bash -c 'open_in_yad_editor'" \
    --button="Run":"bash -c run_yadcode01" \
    --button="Save:bash -c 'save_to_target'" \
    --undecorated \
    --width=$RIGHT_WIDTH \
    --height=$HEIGHT \
    --posx=$LEFT_WIDTH \
    --posy=0

# Capture exit status
ret=$?

# Clean up on exit
rm -f "$TEMP_FILE" "$DND_OUTPUT" 2>/dev/null
exit $ret
