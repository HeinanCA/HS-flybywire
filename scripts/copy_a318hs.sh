#!/bin/bash

set -ex

#remove directory if it exist
rm -rvf ./fbw-common

# copy from FBW COMMON source and HS COMMON into one src
cp -ra ./flybywire/fbw-common/. ./fbw-common
cp -ra ./hsim-a318-common/. ./fbw-common
cp -ra ./hsim-common/. ./fbw-common

#remove directory if it exist
rm -rvf ./build-a318ceo

# create directory
mkdir -p ./build-a318ceo/src
mkdir -p ./build-a318ceo/out

# copy from FBW A32NX source and A318HS into one src
cp -ra ./flybywire/fbw-a32nx/src/behavior/. ./build-a318ceo/src/behavior
cp -ra ./flybywire/fbw-a32nx/src/fonts/. ./build-a318ceo/src/fonts
cp -ra ./flybywire/fbw-a32nx/src/localization/. ./build-a318ceo/src/localization
cp -ra ./flybywire/fbw-a32nx/src/systems/. ./build-a318ceo/src/systems
cp -ra ./flybywire/fbw-a32nx/src/wasm/. ./build-a318ceo/src/wasm

cp -ra ./hsim-a318ceo/.env ./build-a318ceo/.env
cp -ra ./hsim-a318ceo/mach.config.js ./build-a318ceo/mach.config.js

cp -ra ./hsim-a318ceo/src/behavior/. ./build-a318ceo/src/behavior
cp -ra ./hsim-a318ceo/src/localization/. ./build-a318ceo/src/localization
cp -ra ./hsim-a318ceo/src/model/. ./build-a318ceo/src/model
cp -ra ./hsim-a318ceo/src/systems/. ./build-a318ceo/src/systems
cp -ra ./hsim-a318ceo/src/wasm/. ./build-a318ceo/src/wasm

mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo-lock-highlight

mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/CSS
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Fonts
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Images
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/JS
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VCockpit/Instruments/Airliners
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VLivery/Liveries/A318HS_Printer
mkdir -p ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VLivery/Liveries/A318HS_Registration

#cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/CSS/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/CSS/A318HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Fonts/fbw-a32nx/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Fonts/A318HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Images/fbw-a32nx/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Images/A318HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/JS/fbw-a32nx/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/JS/A318HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/A32NX_Core/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/A318HS_Core
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/A32NX_Utils/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/A318HS_Utils
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/FlightElements/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VCockpit/Instruments/FlightElements/A318HS
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VCockpit/Instruments/NavSystems/A320_Neo/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VCockpit/Instruments/NavSystems/A318_Ceo
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Registration/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VLivery/Liveries/A318HS_Registration
cp -ra ./flybywire/fbw-a32nx/src/base/flybywire-aircraft-a320-neo/html_ui/Pages/VLivery/Liveries/A32NX_Printer/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo/html_ui/Pages/VLivery/Liveries/A318HS_Printer

# copy base of A318HS to out
cp -ra ./hsim-a318ceo/src/base/lvfr-horizonsim-airbus-a318-ceo/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo
cp -ra ./hsim-a318ceo/src/base/lvfr-horizonsim-airbus-a318-ceo-lock-highlight/. ./build-a318ceo/out/lvfr-horizonsim-airbus-a318-ceo-lock-highlight

chmod +x ./build-a318ceo/src/wasm/fbw_a320/build.sh
chmod +x ./build-a318ceo/src/wasm/fadec_a320/build.sh
