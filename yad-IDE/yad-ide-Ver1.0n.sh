#!/bin/bash

clear 
echo ""
echo "Program Name: yad Intergrated Development Enviroment"
echo ""
echo "Alpha Version: yad IDE - Code tested on MX Linux Xfce"
echo ""
echo "Filename: yad-ide-V1.03n.sh | March 29, 2026"
echo ""
echo "Find lasted version here: https://github.com/offternet/yad"
echo ""
echo "Requires: yad gui 10.x+ required on a GTK3.22+ system. (Compile on your system- 10MB)"
echo "yad source is here: https://github.com/v1cont/yad/releases"
echo ""
echo "Can also use the self contained yad-13.AppImage here: (73MB)"
echo "https://github.com/sonic2kk/steamtinkerlaunch-tweaks/releases"
echo ""
echo "MIT LICENSE 2026 (c) Robert J. Cooper https://LinDnd.com"
echo "Your use of this alpha software version is your acceptace of the MIT LICENSE"
echo ""
read -p "Press the Enterkey to load yad IDE" 


clear

echo "Now Loading yad gui IDE- Alpha Version 1.0n"
echo ""

yad --about --pname="yad IDE" --pversion="Ver1.0n-Alpha" --license=MIT --comments="(c) 2026" --authors="Robert J. Cooper" --website="https://github.com/offternet" --website="https://LinDnD.com" --width=500 --height=500 --image="/production/yad/buttons/yad-ide.gif" 


#===================================================================
# ADJUSTABLE PRESETS - Base values for 1366x768 reference screen
#===================================================================

# File to store screen configuration data
DATA_FILE="/tmp/screen-resolution.txt"

# Restart flag file
RESTART_FLAG="/tmp/yad_ide_restart"

# Initialize default values
REF_WIDTH="1366"
REF_HEIGHT="768"
LEFT_WIDTH_BASE="100"
LEFT_POSX_BASE="0"
LEFT_POSY_BASE="0"
LEFT_BOTTOM_MARGIN_BASE="6"
RIGHT_POSX_BASE="450"
RIGHT_POSY_BASE="0"
RIGHT_WIDTH_OFFSET_BASE="1"
RIGHT_BOTTOM_MARGIN_BASE="30"

# Auto-scale setting
AUTO_SCALE="true"

# Clean up any old restart flag
rm -f "$RESTART_FLAG" 2>/dev/null

#===================================================================
# AUTO-DETECT FUNCTION
#===================================================================

# Function to auto-detect optimal screen configuration
auto_detect_config() {
    # Get current screen resolution
    local current_width current_height
    read current_width current_height <<< $(xdpyinfo | grep dimensions | awk '{print $2}' | tr 'x' ' ')
    
    echo "Detecting optimal configuration for ${current_width}x${current_height}..."
    
    # Calculate optimal values based on screen size
    local new_ref_width="$current_width"
    local new_ref_height="$current_height"
    
    # Calculate left panel width (10-15% of screen width, but not less than 100)
    local new_left_width_base=$(( current_width * 10 / 100 ))
    [ $new_left_width_base -lt 100 ] && new_left_width_base=100
    [ $new_left_width_base -gt 250 ] && new_left_width_base=250
    
    # Left panel position (always at left edge)
    local new_left_posx_base="0"
    local new_left_posy_base="0"
    
    # Left bottom margin (2-4% of height)
    local new_left_bottom_margin_base=$(( current_height * 3 / 100 ))
    [ $new_left_bottom_margin_base -lt 6 ] && new_left_bottom_margin_base=6
    [ $new_left_bottom_margin_base -gt 30 ] && new_left_bottom_margin_base=30
    
    # Calculate right panel X position (left panel width + 10px gap)
    local new_right_posx_base=$(( new_left_width_base + 10 ))
    
    # Right panel Y position (usually 0 for top alignment)
    local new_right_posy_base="0"
    
    # Calculate right panel width offset (5-10px margin)
    local new_right_width_offset_base="10"
    
    # Right bottom margin (3-5% of height for aesthetics)
    local new_right_bottom_margin_base=$(( current_height * 4 / 100 ))
    [ $new_right_bottom_margin_base -lt 30 ] && new_right_bottom_margin_base=30
    [ $new_right_bottom_margin_base -gt 50 ] && new_right_bottom_margin_base=50
    
    # Show detected values to user
    yad --info \
        --title="Screen Detection Results" \
        --center \
        --text="<b>Detected Screen: ${current_width}x${current_height}</b>\n\n<b>Calculated Optimal Values:</b>\n\nREF_WIDTH: $new_ref_width\nREF_HEIGHT: $new_ref_height\nLEFT_WIDTH_BASE: $new_left_width_base\nLEFT_POSX_BASE: $new_left_posx_base\nLEFT_POSY_BASE: $new_left_posy_base\nLEFT_BOTTOM_MARGIN_BASE: $new_left_bottom_margin_base\nRIGHT_POSX_BASE: $new_right_posx_base\nRIGHT_POSY_BASE: $new_right_posy_base\nRIGHT_WIDTH_OFFSET_BASE: $new_right_width_offset_base\nRIGHT_BOTTOM_MARGIN_BASE: $new_right_bottom_margin_base\n\n<b>These values will be saved to configuration file.</b>\n\nUse 'Screen Config' button for fine adjustments." \
        --width=500 \
        --height=500 \
        --button="Cancel:1" \
        --button="Apply - Restart:0"
    
    if [ $? -eq 0 ]; then
        # Save the detected values
        cat > "$DATA_FILE" << EOF
$new_ref_width
$new_ref_height
$new_left_width_base
$new_left_posx_base
$new_left_posy_base
$new_left_bottom_margin_base
$new_right_posx_base
$new_right_posy_base
$new_right_width_offset_base
$new_right_bottom_margin_base
EOF
        
        # Update global variables
        REF_WIDTH="$new_ref_width"
        REF_HEIGHT="$new_ref_height"
        LEFT_WIDTH_BASE="$new_left_width_base"
        LEFT_POSX_BASE="$new_left_posx_base"
        LEFT_POSY_BASE="$new_left_posy_base"
        LEFT_BOTTOM_MARGIN_BASE="$new_left_bottom_margin_base"
        RIGHT_POSX_BASE="$new_right_posx_base"
        RIGHT_POSY_BASE="$new_right_posy_base"
        RIGHT_WIDTH_OFFSET_BASE="$new_right_width_offset_base"
        RIGHT_BOTTOM_MARGIN_BASE="$new_right_bottom_margin_base"
        
        # Export variables
        export REF_WIDTH REF_HEIGHT LEFT_WIDTH_BASE LEFT_POSX_BASE LEFT_POSY_BASE
        export LEFT_BOTTOM_MARGIN_BASE RIGHT_POSX_BASE RIGHT_POSY_BASE
        export RIGHT_WIDTH_OFFSET_BASE RIGHT_BOTTOM_MARGIN_BASE
        
        # Create restart flag
        touch "/tmp/yad_ide_restart"
        
        # Show success message
        yad --info \
            --title="Auto-Detect Complete" \
            --center \
            --text="✅ Screen configuration auto-detected and saved!\n\nPlease click QUIT to restart and apply the new settings." \
            --timeout=3 \
            --width=400 \
            --on-top \
            --no-buttons &
    fi
}
export -f auto_detect_config

#===================================================================
# SCREEN CONFIGURATION FUNCTION
#===================================================================

# Function to display the screen configuration form
show_screen_config() {
    # Use absolute path for data file
    local DATA_FILE="/tmp/screen-resolution.txt"
    
    # Initialize file if it doesn't exist
    if [ ! -f "$DATA_FILE" ]; then
        cat > "$DATA_FILE" << EOF
1366
768
100
0
0
6
450
0
1
30
EOF
    fi
    
    # Load current values from file
    local values=()
    while IFS= read -r line; do
        values+=("$line")
    done < "$DATA_FILE"
    
    # Ensure we have exactly 10 values
    while [ ${#values[@]} -lt 10 ]; do
        values+=("0")
    done
    
    # Show form and capture output
    result=$(yad --form \
        --title="Screen Resolution Configuration" \
        --field="Resolution Width:NUM" \
        --field="Resolution Height:NUM" \
        --field="Left Window Width: NUM" \
        --field="Left Window posx: NUM" \
        --field="Left Window posy: NUM" \
        --field="Left Window Bottom Margin: NUM" \
        --field="Right Window posx: NUM" \
        --field="Right Window posy: NUM" \
        --field="Right Window Right Margin: NUM" \
        --field="Right Window Bottom Margin: NUM" \
        --width=600 \
        --height=550 \
        --columns=1 \
        --center \
        --on-top \
        --button="Auto-Detect:3" \
        --button="Load from File:2" \
        --button="Save:0" \
        --button="Cancel:1" \
        --text="<b>Screen Configuration Editor</b>\n\nEdit values below (numeric only, 1-4 digits)\n\nConfiguration file: $DATA_FILE" \
        "${values[0]}" "${values[1]}" "${values[2]}" "${values[3]}" "${values[4]}" \
        "${values[5]}" "${values[6]}" "${values[7]}" "${values[8]}" "${values[9]}")
    
    local exit_code=$?
    
    case $exit_code in
        0)  # Save button clicked
            IFS='|' read -r -a new_values <<< "$result"
            
            # Clean and validate values
            for i in 0 1 2 3 4 5 6 7 8 9; do
                # Remove any non-numeric characters
                new_values[$i]=$(echo "${new_values[$i]}" | sed 's/[^0-9]//g')
                # Set to 0 if empty
                if [ -z "${new_values[$i]}" ]; then
                    new_values[$i]="0"
                fi
                # Limit to 4 digits
                if [ ${#new_values[$i]} -gt 4 ]; then
                    new_values[$i]=${new_values[$i]:0:4}
                fi
            done
            
            # Save to file
            cat > "$DATA_FILE" << EOF
${new_values[0]}
${new_values[1]}
${new_values[2]}
${new_values[3]}
${new_values[4]}
${new_values[5]}
${new_values[6]}
${new_values[7]}
${new_values[8]}
${new_values[9]}
EOF
            
            # Update global variables
            REF_WIDTH="${new_values[0]}"
            REF_HEIGHT="${new_values[1]}"
            LEFT_WIDTH_BASE="${new_values[2]}"
            LEFT_POSX_BASE="${new_values[3]}"
            LEFT_POSY_BASE="${new_values[4]}"
            LEFT_BOTTOM_MARGIN_BASE="${new_values[5]}"
            RIGHT_POSX_BASE="${new_values[6]}"
            RIGHT_POSY_BASE="${new_values[7]}"
            RIGHT_WIDTH_OFFSET_BASE="${new_values[8]}"
            RIGHT_BOTTOM_MARGIN_BASE="${new_values[9]}"
            
            # Export variables for child processes
            export REF_WIDTH REF_HEIGHT LEFT_WIDTH_BASE LEFT_POSX_BASE LEFT_POSY_BASE
            export LEFT_BOTTOM_MARGIN_BASE RIGHT_POSX_BASE RIGHT_POSY_BASE
            export RIGHT_WIDTH_OFFSET_BASE RIGHT_BOTTOM_MARGIN_BASE
            
            # Show success message
            yad --info \
                --title="Success" \
                --center \
                --text="✅ Configuration saved successfully!\n\nFile: $DATA_FILE\n\nNew values:\nREF_WIDTH: $REF_WIDTH\nREF_HEIGHT: $REF_HEIGHT\nLEFT_WIDTH_BASE: $LEFT_WIDTH_BASE\nLEFT_POSX_BASE: $LEFT_POSX_BASE\nLEFT_POSY_BASE: $LEFT_POSY_BASE\nLEFT_BOTTOM_MARGIN_BASE: $LEFT_BOTTOM_MARGIN_BASE\nRIGHT_POSX_BASE: $RIGHT_POSX_BASE\nRIGHT_POSY_BASE: $RIGHT_POSY_BASE\nRIGHT_WIDTH_OFFSET_BASE: $RIGHT_WIDTH_OFFSET_BASE\nRIGHT_BOTTOM_MARGIN_BASE: $RIGHT_BOTTOM_MARGIN_BASE" \
                --timeout=5 \
                --width=500 \
                --no-buttons &
            
            # Ask about restart
            yad --question \
                --title="Restart Required" \
                --center \
                --text="Configuration saved successfully!\n\nRestart now to apply changes?\n\n(You will need to click QUIT to complete restart)" \
                --on-top \
                --button="Later:1" \
                --button="Restart Now:0"
            
            if [ $? -eq 0 ]; then
                # Create restart flag
                touch "/tmp/yad_ide_restart"
                # Show message about clicking QUIT
                yad --info \
                    --title="Restart Pending" \
                    --center \
                    --text="✅ Configuration saved!\n\nPlease click the QUIT button to restart the application.\n\nThe new settings will be applied on restart." \
                    --timeout=3 \
                    --on-top \
                    --width=400 \
                    --no-buttons &
            fi
            ;;
        2)  # Load from File button clicked
            # Just reopen the form - this will reload the file
            show_screen_config
            return
            ;;
        3)  # Auto-Detect button clicked
            # Close current form and run auto-detect
            auto_detect_config
            # Reopen the form after auto-detect
            show_screen_config
            return
            ;;
        1)  # Cancel button clicked
            # Do nothing
            ;;
    esac
}
export -f show_screen_config

#===================================================================
# Load configuration from file at startup
#===================================================================
if [ -f "$DATA_FILE" ]; then
    line_num=0
    while IFS= read -r line; do
        case $line_num in
            0) REF_WIDTH="$line" ;;
            1) REF_HEIGHT="$line" ;;
            2) LEFT_WIDTH_BASE="$line" ;;
            3) LEFT_POSX_BASE="$line" ;;
            4) LEFT_POSY_BASE="$line" ;;
            5) LEFT_BOTTOM_MARGIN_BASE="$line" ;;
            6) RIGHT_POSX_BASE="$line" ;;
            7) RIGHT_POSY_BASE="$line" ;;
            8) RIGHT_WIDTH_OFFSET_BASE="$line" ;;
            9) RIGHT_BOTTOM_MARGIN_BASE="$line" ;;
        esac
        line_num=$((line_num + 1))
        [ $line_num -eq 10 ] && break
    done < "$DATA_FILE"
fi

# Export variables for child processes
export REF_WIDTH REF_HEIGHT LEFT_WIDTH_BASE LEFT_POSX_BASE LEFT_POSY_BASE
export LEFT_BOTTOM_MARGIN_BASE RIGHT_POSX_BASE RIGHT_POSY_BASE
export RIGHT_WIDTH_OFFSET_BASE RIGHT_BOTTOM_MARGIN_BASE

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

#===================================================================

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
# Function to close the application with restart support
close_question() {
    # Disable cleanup temporarily
    CLEANUP_ENABLED=0
    
    yad --question \
        --title="Exit" \
        --center \
        --text="Do you want to exit The LinDnD yad gui Integrated System?" \
        --on-top \
        --button="Cancel:1" \
        --button="Exit:0"
    
    if [ $? -eq 0 ]; then
        # Check if we need to restart
        if [ -f "/tmp/yad_ide_restart" ]; then
            # Re-enable cleanup
            CLEANUP_ENABLED=1
            cleanup
            clear
            rm -f "/tmp/yad_ide_restart"
            # Restart the program
            echo "Restarting yad IDE with new configuration..."
            sleep 1
            exec /production/yad/yad-ide.sh
        else
            # Normal exit
            CLEANUP_ENABLED=1
            cleanup
            clear
            exit 0
        fi
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
            # Create a temporary marker file to force update
            local marker_file="/tmp/yad_marker_$$"
            sleep 2
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
                --timeout=4 \
                --on-top \
                --width=300 \
                --no-buttons &
        fi
    else
        yad --info \
            --title="Empty" \
            --center \
            --text="File already empty." \
            --timeout=4 \
            --on-top \
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
            --on-top \
            --fontname="Monospace 10" \
            --button="Cancel:1" \
            --button="Save:0")
        
        if [ $? -eq 0 ] && [ -n "$edited_content" ]; then
            echo "$edited_content" > "$TEMP_FILE"
            SUCCESS_COUNT=$(grep -c "^# --- Start of file:" "$TEMP_FILE")
            export SUCCESS_COUNT
            
            yad --info --title="Saved" --text="Changes saved." --on-top --timeout=4 --width=300 --no-buttons &
        fi
    else
        yad --warning --title="Empty" --text="No content to edit." --width=300 --ont-top --timeout=4 --no-buttons
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
            --on-top \
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
                --on-top \
                --timeout=4 \
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
    # Just call close_question which handles restart logic
    close_question
}
export -f quit_yad



help_ide () {
    
 yad --html --browser --uri="https://raw.githubusercontent.com/offternet/yad/refs/heads/main/README.md" --width=1000 --height=600 --on-top --title="Help from Online Github page" --center --button="Close:1" 
 
}
export -f help_ide

show_license () {

yad --html --browser --uri="file:///production/yad/html/mit-license.html" --width=800 --height=600 --center --on-top --button="Close:1"

}
export -f show_license


about_yadIDE () {

yad --html --browser --uri="file:///production/yad/html/about-yad-ide.html" --width=800 --height=600 --center --on-top --button="Close:1"

}
export -f about_yadIDE

show_author () {

yad --about --pname="yad IDE" --pversion="Ver1.0n-Alpha" --license=MIT --comments="(c) 2026" --authors="Robert J. Cooper" --website="https://github.com/offternet" --website="https://LinDnD.com" --width=500 --height=500 --image="/production/yad/buttons/yad-ide.gif"

}
export -f show_author


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
    --button="Clear:bash -c 'clear_temp_file'" \
    --button="Edit:bash -c 'open_in_yad_editor'" \
    --button="Run:bash -c 'run_yadcode01'" \
    --button="Save:bash -c 'save_to_target'"  &
    
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
yad2 --plug=$fkey --tabnum=1 yad --html --uri="file:///production/yad/html/yad-ide.html" --alt=alt --title=title &
yad2 --plug=$fkey --tabnum=2 yad --html --uri="file:///production/yad/html/general.html" &
yad2 --plug=$fkey --tabnum=3 yad --html --uri="file:///production/yad/html/common.html"  &
yad2 --plug=$fkey --tabnum=4 yad --html --uri="file:///production/yad/html/calendar.html" &
yad2 --plug=$fkey --tabnum=5 yad --html --uri="file:///production/yad/html/dnd.html" &
yad2 --plug=$fkey --tabnum=6 yad --html --uri="file:///production/yad/html/form-entry.html"  &
yad2 --plug=$fkey --tabnum=7 yad --html --uri="file:///production/yad/html/html.html"  &
yad2 --plug=$fkey --tabnum=8 yad --html --uri="file:///production/yad/html/icons.html"  &
yad2 --plug=$fkey --tabnum=9 yad --html --uri="file:///production/yad/html/list.html"  &
yad2 --plug=$fkey --tabnum=10 yad --html --uri="file:///production/yad/html/notebook-paned.html"  &
yad2 --plug=$fkey --tabnum=11 yad --html --uri="file:///production/yad/html/text-text-info.html" &
yad2 --plug=$fkey --tabnum=12 yad --html --uri="file:///production/yad/html/misc.html" &



# --button="scale" --tab="color"  --tab="app" --button="progress"
# The notebook container - using geometry with adjustable presets
yad2 --notebook --key="$fkey" \
    --tab="Main" --tab="General" --tab="Common" --tab="calendar"  --tab="dnd" --tab="form-entry" --tab="html"  --tab="icons" --tab="list" --tab="notebook-paned" --tab="text/text-info" --tab="Misc Dialogs"  \
    --title="LinDnD - yad Integrated Development Environment Framework - bash + yad Gui 13" \
    --geometry=${RIGHT_WIDTH}x${RIGHT_HEIGHT}+${RIGHT_POSX}+${RIGHT_POSY} \
    --buttons-layout=start \
    --buttons-layout=start \
     --button="QUIT:bash -c 'quit_yad'" \
     --button="Help:bash -c 'help_ide'" \
     --button="About:bash -c 'about_yadIDE'" \
     --button="License:bash -c 'show_license'" \
     --button="Author:bash -c 'show_author'" \
     --button="Screen Config:bash -c 'show_screen_config'"  &
   
NOTEBOOK_PID=$!

# Wait for the main yad process to finish
wait $MAIN_YAD_PID

# Normal exit (restart is handled in close_question)
CLEANUP_ENABLED=1
cleanup
exit 0
