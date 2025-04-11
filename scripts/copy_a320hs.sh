#!/bin/bash

# Enhanced A320 Build Script
# This script organizes and builds the A320 project components

# Color definitions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

log_section() {
    echo -e "\n${CYAN}${BOLD}===== $1 =====${RESET}\n"
}

# Error handling function
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Failed at line ${line_number} with exit code ${exit_code}"

    case $line_number in
        # Add specific error handling for critical sections as needed
        *)
            log_error "Error occurred during execution. Check your directory structure and permissions."
            ;;
    esac

    exit $exit_code
}

# Clean up on error function
cleanup_on_error() {
    log_warning "Cleaning up partially built directories..."

    # Only clean up directories that might be corrupted or incomplete
    if [ -d "./fbw-common" ]; then
        rm -rf ./fbw-common
        log_info "Removed fbw-common directory"
    fi

    if [ -d "./build-a320ceo" ]; then
        rm -rf ./build-a320ceo
        log_info "Removed build-a320ceo directory"
    fi

    log_info "Cleanup complete"
    exit 1
}

# Trap errors and call error handler with line number
trap 'handle_error $LINENO' ERR
# Trap interrupts (Ctrl+C) and cleanup
trap 'log_error "Script interrupted by user"; cleanup_on_error' INT TERM

# Enable error tracing
set -e

# Print script header
echo -e "${BOLD}${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║               A320 Build Script                   ║"
echo "╚═══════════════════════════════════════════════════╝${RESET}"

# Check for essential directories before starting
check_prereqs() {
    local missing=0

    log_section "Checking prerequisites"

    if [ ! -d "./flybywire" ]; then
        log_error "flybywire directory not found!"
        missing=1
    else
        log_info "flybywire directory found ✓"
    fi

    if [ ! -d "./hsim-a320-common" ]; then
        log_error "hsim-a320-common directory not found!"
        missing=1
    else
        log_info "hsim-a320-common directory found ✓"
    fi

    if [ ! -d "./hsim-common" ]; then
        log_error "hsim-common directory not found!"
        missing=1
    else
        log_info "hsim-common directory found ✓"
    fi

    if [ ! -d "./hsim-a320ceo" ]; then
        log_error "hsim-a320ceo directory not found!"
        missing=1
    else
        log_info "hsim-a320ceo directory found ✓"
    fi

    if [ $missing -eq 1 ]; then
        log_error "One or more required directories are missing. Aborting..."
        exit 1
    fi

    log_success "All prerequisite directories found"
}

# Run prerequisite check
check_prereqs

# Set up common directory
log_section "Setting up common directory"

if [ -d "./fbw-common" ]; then
    log_warning "Removing existing fbw-common directory"
    rm -rf ./fbw-common
fi

log_info "Copying common files from multiple sources..."
# Function to copy with error checking
safe_copy() {
    local src="$1"
    local dest="$2"
    local description="$3"

    if [ ! -d "$src" ] && [ ! -f "$src" ]; then
        log_error "Source $src does not exist!"
        return 1
    fi

    cp -ra "$src" "$dest"
    if [ $? -ne 0 ]; then
        log_error "Failed to copy $description from $src to $dest"
        return 1
    else
        log_info "Copied $description successfully"
        return 0
    fi
}

safe_copy "./flybywire/fbw-common/." "./fbw-common" "FlyByWire common files"
safe_copy "./hsim-a320-common/." "./fbw-common" "HorizSim A320 common files"
safe_copy "./hsim-common/." "./fbw-common" "HorizSim common files"
log_success "Common directory setup complete"

# Set up build directory
log_section "Setting up build directory"

if [ -d "./build-a320ceo" ]; then
    log_warning "Removing existing build-a320ceo directory"
    rm -rf ./build-a320ceo
fi

log_info "Creating build directory structure..."
mkdir -p ./build-a320ceo/src
mkdir -p ./build-a320ceo/out
log_success "Build directory structure created"

# Copy FlyByWire sources
log_section "Copying FlyByWire A32NX sources"

log_info "Copying main components..."
cp -ra ./flybywire/fbw-a32nx/src/behavior/. ./build-a320ceo/src/behavior
cp -ra ./flybywire/fbw-a32nx/src/fonts/. ./build-a320ceo/src/fonts
cp -ra ./flybywire/fbw-a32nx/src/localization/. ./build-a320ceo/src/localization
cp -ra ./flybywire/fbw-a32nx/src/systems/. ./build-a320ceo/src/systems
cp -ra ./flybywire/fbw-a32nx/src/wasm/. ./build-a320ceo/src/wasm

log_info "Copying and renaming EWD components..."
cp -ra ./flybywire/fbw-a32nx/src/systems/instruments/src/EWD/. ./build-a320ceo/src/systems/instruments/src/EWDcfm
cp -ra ./flybywire/fbw-a32nx/src/systems/instruments/src/EWD/. ./build-a320ceo/src/systems/instruments/src/EWDiae

log_info "Copying and renaming FMGC components..."
cp -ra ./flybywire/fbw-a32nx/src/systems/fmgc/. ./build-a320ceo/src/systems/fmgcCFMSL
cp -ra ./flybywire/fbw-a32nx/src/systems/fmgc/. ./build-a320ceo/src/systems/fmgcIAE
cp -ra ./flybywire/fbw-a32nx/src/systems/fmgc/. ./build-a320ceo/src/systems/fmgcIAESL
log_success "FlyByWire components copied"

# Copy HorizSim sources
log_section "Copying HorizSim A320CEO sources"

log_info "Copying configuration files..."
cp -ra ./hsim-a320ceo/.env ./build-a320ceo/.env
cp -ra ./hsim-a320ceo/mach.config.js ./build-a320ceo/mach.config.js

log_info "Copying main components..."
cp -ra ./hsim-a320ceo/src/behavior/. ./build-a320ceo/src/behavior
cp -ra ./hsim-a320ceo/src/localization/. ./build-a320ceo/src/localization
cp -ra ./hsim-a320ceo/src/model/. ./build-a320ceo/src/model
cp -ra ./hsim-a320ceo/src/systems/. ./build-a320ceo/src/systems
cp -ra ./hsim-a320ceo/src/wasm/. ./build-a320ceo/src/wasm
log_success "HorizSim components copied"

# Create output directory structure
log_section "Creating output directory structure"

log_info "Creating main output directories..."
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo-lock-highlight

log_info "Creating UI structure directories..."
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/CSS
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Fonts
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Images
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/JS
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/Airliners
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Printer
mkdir -p ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Registration
log_success "Output directory structure created"

# Copy UI components
log_section "Copying UI components"

log_info "Copying and renaming FlyByWire UI components..."
# Commented out in original script
#cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/CSS/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/CSS/A320HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Fonts/fbw-a32nx/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Fonts/A320HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Images/fbw-a32nx/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Images/A320HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/JS/fbw-a32nx/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/JS/A320HS
cp -ra ./flybywire/fbw-a32nx/src/systems/instruments/src/MCDU/legacy/A32NX_Core/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/A320HS_Core
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/A32NX_Utils/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/A320HS_Utils
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/FlightElements/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements/A320HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/NavSystems/A320_Neo/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems/A320_Ceo
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Registration/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Registration
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Printer/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo/html_ui/Pages/VLivery/Liveries/A320HS_Printer
log_success "UI components copied and renamed"

# Copy base files
log_section "Copying base files"

log_info "Copying HorizSim base files to output..."
cp -ra ./hsim-a320ceo/src/base/lvfr-horizonsim-airbus-a320-ceo/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo
cp -ra ./hsim-a320ceo/src/base/lvfr-horizonsim-airbus-a320-ceo-lock-highlight/. ./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo-lock-highlight
log_success "Base files copied"

# Cleanup and permissions
log_section "Finalizing build"

log_info "Removing unnecessary directories..."
rm -rf ./build-a320ceo/src/systems/instruments/src/EWD

log_info "Setting executable permissions..."
chmod +x ./build-a320ceo/src/wasm/fbw_a320/build.sh
chmod +x ./build-a320ceo/src/wasm/fadec_a320/build.sh
log_success "Permissions set"

# Check if everything exists as expected
log_section "Verifying build output"

# Function to verify directories exist
verify_dir() {
    if [ ! -d "$1" ]; then
        log_error "Directory $1 was not created properly!"
        return 1
    else
        log_info "Directory $1 exists ✓"
        return 0
    fi
}

# Function to check if file exists
verify_file() {
    if [ ! -f "$1" ]; then
        log_error "File $1 was not copied properly!"
        return 1
    else
        log_info "File $1 exists ✓"
        return 0
    fi
}

# Verify critical directories
verify_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo"
verify_dir "./build-a320ceo/out/lvfr-horizonsim-airbus-a320-ceo-lock-highlight"
verify_dir "./build-a320ceo/src/systems/instruments/src/EWDcfm"
verify_dir "./build-a320ceo/src/systems/fmgcCFMSL"

# Verify critical executable files
verify_file "./build-a320ceo/src/wasm/fbw_a320/build.sh"
verify_file "./build-a320ceo/src/wasm/fadec_a320/build.sh"

# Check if executables have correct permissions
if [ ! -x "./build-a320ceo/src/wasm/fbw_a320/build.sh" ]; then
    log_error "build.sh does not have executable permissions!"
    chmod +x "./build-a320ceo/src/wasm/fbw_a320/build.sh"
    log_warning "Fixed permissions for fbw_a320/build.sh"
fi

if [ ! -x "./build-a320ceo/src/wasm/fadec_a320/build.sh" ]; then
    log_error "build.sh does not have executable permissions!"
    chmod +x "./build-a320ceo/src/wasm/fadec_a320/build.sh"
    log_warning "Fixed permissions for fadec_a320/build.sh"
fi

log_section "Build completed successfully"
echo -e "${GREEN}${BOLD}✓ All operations completed successfully${RESET}"
echo -e "${CYAN}Build output available at:${RESET} ./build-a320ceo/out"
