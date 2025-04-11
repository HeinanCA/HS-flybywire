#!/bin/bash

# Exit on error, but handle them more carefully
set -e

# Function to show operation status
show_status() {
  echo "----------------------------------------------"
  echo "🔄 $1"
  echo "----------------------------------------------"
}

# Function to validate directory exists
validate_dir() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo "❌ ERROR: Directory $dir does not exist!"
    return 1
  else
    echo "✅ Directory $dir exists."
    return 0
  fi
}

# Function to create directory if it doesn't exist
ensure_dir() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo "📁 Creating directory: $dir"
    mkdir -p "$dir"
  else
    echo "✅ Directory already exists: $dir"
  fi
}

# Function to clean directory if it exists
clean_dir() {
  local dir=$1
  if [ -d "$dir" ]; then
    show_status "Removing directory: $dir"
    rm -rf "$dir"
  fi
}

# Function to copy files with validation
copy_files() {
  local src=$1
  local dest=$2

  if [ ! -e "$src" ]; then
    echo "❌ ERROR: Source $src does not exist!"
    return 1
  fi

  ensure_dir "$(dirname "$dest")"
  echo "📋 Copying: $src -> $dest"
  cp -rav "$src" "$dest"

  # Verify copy was successful
  if [ $? -eq 0 ]; then
    echo "✅ Copy successful!"
    return 0
  else
    echo "❌ ERROR: Copy failed!"
    return 1
  fi
}

# Main execution starts here
show_status "Starting A320 Build Process"

# Step 1: Clean and setup fbw-common directory
show_status "Setting up FBW Common directory"
clean_dir "./fbw-common"

# Validate source directories
validate_dir "./flybywire/fbw-common" || { echo "⚠️ Missing ./flybywire/fbw-common, build may fail!"; }
validate_dir "./hsim-a320-common" || { echo "⚠️ Missing ./hsim-a320-common, build may fail!"; }
validate_dir "./hsim-common" || { echo "⚠️ Missing ./hsim-common, build may fail!"; }

# Copy FBW COMMON source and HDW COMMON into one src
show_status "Copying common files"
copy_files "./flybywire/fbw-common/." "./fbw-common"
copy_files "./hsim-a320-common/." "./fbw-common"
copy_files "./hsim-common/." "./fbw-common"

# Step 2: Clean and setup build directory
show_status "Setting up build directory"
clean_dir "./build-a320ceo"

# Create main directories
show_status "Creating build directory structure"
ensure_dir "./build-a320ceo/src"
ensure_dir "./build-a320ceo/out"

# Step 3: Copy from FBW A32NX source and A320HS into src
show_status "Copying A32NX source files"

# Validate FBW source directory
validate_dir "./flybywire/fbw-a32nx" || { echo "❌ ERROR: FBW source missing!"; exit 1; }

# Copy core components
copy_files "./flybywire/fbw-a32nx/src/behavior/." "./build-a320ceo/src/behavior"
copy_files "./flybywire/fbw-a32nx/src/fonts/." "./build-a320ceo/src/fonts"
copy_files "./flybywire/fbw-a32nx/src/localization/." "./build-a320ceo/src/localization"
copy_files "./flybywire/fbw-a32nx/src/systems/." "./build-a320ceo/src/systems"
copy_files "./flybywire/fbw-a32nx/src/wasm/." "./build-a320ceo/src/wasm"

# Copy specialized components
show_status "Copying specialized components (EWD, FMGC)"
copy_files "./flybywire/fbw-a32nx/src/systems/instruments/src/EWD/." "./build-a320ceo/src/systems/instruments/src/EWDcfm"
copy_files "./flybywire/fbw-a32nx/src/systems/instruments/src/EWD/." "./build-a320ceo/src/systems/instruments/src/EWDiae"

copy_files "./flybywire/fbw-a32nx/src/systems/fmgc/." "./build-a320ceo/src/systems/fmgcCFMSL"
copy_files "./flybywire/fbw-a32nx/src/systems/fmgc/." "./build-a320ceo/src/systems/fmgcIAE"
copy_files "./flybywire/fbw-a32nx/src/systems/fmgc/." "./build-a320ceo/src/systems/fmgcIAESL"

# Copy A320HS specific files
show_status "Copying HSim A320CEO files"
validate_dir "./hsim-a320ceo" || { echo "❌ ERROR: HSim source missing!"; exit 1; }

copy_files "./hsim-a320ceo/.env" "./build-a320ceo/.env"
copy_files "./hsim-a320ceo/mach.config.js" "./build-a320ceo/mach.config.js"

copy_files "./hsim-a320ceo/src/behavior/." "./build-a320ceo/src/behavior"
copy_files "./hsim-a320ceo/src/localization/." "./build-a320ceo/src/localization"
copy_files "./hsim-a320ceo/src/model/." "./build-a320ceo/src/model"
copy_files "./hsim-a320ceo/src/systems/." "./build-a320ceo/src/systems"
copy_files "./hsim-a320ceo/src/wasm/." "./build-a320ceo/src/wasm"

# Step 4: Create output directory structure
show_status "Creating output directory structure"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo-lock-highlight"

ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/CSS"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Fonts"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Images"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/JS"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/Airliners"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Printer"
ensure_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Registration"

# Step 5: Copy assets to output directories
show_status "Copying assets to output directories"
# Note: Commented out css copy is preserved as in original
#copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/CSS/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/CSS/A320HS"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Fonts/fbw-a32nx/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Fonts/A320HS"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Images/fbw-a32nx/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Images/A320HS"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/JS/fbw-a32nx/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/JS/A320HS"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/A32NX_Core/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/A320HS_Core"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/A32NX_Utils/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/A320HS_Utils"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/FlightElements/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements/A320HS"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/NavSystems/A320_Neo/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems/A320_Ceo"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Registration/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Registration"
copy_files "./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Printer/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Printer"

# Copy base of A320HS to out
show_status "Copying A320HS base files"
copy_files "./hsim-a320ceo/src/base/lvfr-horizonsim-airbus-a320-ceo/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo"
copy_files "./hsim-a320ceo/src/base/lvfr-horizonsim-airbus-a320-ceo-lock-highlight/." "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo-lock-highlight"

# Step 6: Final cleanup and permissions
show_status "Performing final cleanup and setting permissions"
rm -rf "./build-a320ceo/src/systems/instruments/src/EWD"

show_status "Setting executable permissions"
if [ -f "./build-a320ceo/src/wasm/fbw_a320/build.sh" ]; then
  chmod +x ./build-a320ceo/src/wasm/fbw_a320/build.sh
  echo "✅ Set executable permission for fbw_a320/build.sh"
else
  echo "⚠️ Warning: fbw_a320/build.sh not found"
fi

if [ -f "./build-a320ceo/src/wasm/fadec_a320/build.sh" ]; then
  chmod +x ./build-a320ceo/src/wasm/fadec_a320/build.sh
  echo "✅ Set executable permission for fadec_a320/build.sh"
else
  echo "⚠️ Warning: fadec_a320/build.sh not found"
fi

show_status "A320 Build Process Completed Successfully"
echo "Build output located at: ./build-a320ceo/out/"