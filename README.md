![Horizon Simulations](./branding/Horizon_Simulations.png)

# Horizon Simulations - Airbus A32(X)

The Horizon Simulations project is an Airbus aircraft development effort based on [FlyByWire Simulations](https://flybywiresim.com/) A32NX.

## Aircraft Models

The following aircraft configurations are currently simulated or targeted:

### A321neo (LR) CFM LEAP

```
Model       A321-251N
Engine      CFM LEAP 1A-32
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A321neo (LR) Pratt & Whitney

```
Model       A321-271N
Engine      Pratt & Whitney PW1130G-JM
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A318-100 CFM (ceo)

```
Model       A318-115
Engine      CFM56-5B7
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A319-100 CFM (ceo)

```
Model       A319-115
Engine      CFM56-5B5
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A319-100 IAE (ceo)

```
Model       A319-133
Engine      IAE V2524-A5
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A320-200 CFM (ceo)

```
Model       A320-214
Engine      CFM56-5B4/P
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

### A320-200 IAE (ceo)

```
Model       A320-232
Engine      IAE V2527-A5
APU         APS3200
FMS         Honeywell Release H3
FWC Std.    H2F9C
RA          Honeywell ALA-52B
TAWS        Honeywell EGPWS
ACAS        Honeywell TPA-100B
ATC         Honeywell TRA-100B
MMR         Honeywell iMMR
WXR         Honeywell RDR-4000
```

## Build Instructions

### Prerequisites
- Docker Desktop (preferably with WSL2 backend)
- NodeJS (latest LTS version)
- Git for Windows

### Build Process

#### 1. Initial Setup

Install dependencies and initialize the FlyByWire submodule:

**PowerShell:**
```shell
npm install --save-dev
git submodule init
git submodule update flybywire
.\scripts\dev-env\run.cmd ./scripts/setup.sh
```

**Git Bash/Linux:**
```shell
npm install --save-dev
git submodule init
git submodule update flybywire
./scripts/dev-env/run.sh ./scripts/setup.sh
```

#### 2. Copy Source Files

Choose the aircraft model you want to build:

**A318ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/copy_a318hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/copy_a318hs.sh
```

**A319ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/copy_a319hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/copy_a319hs.sh
```

**A320ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/copy_a320hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/copy_a320hs.sh
```

**A321neo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/copy_a321hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/copy_a321hs.sh
```

#### 3. Build the Aircraft Module

Build your selected aircraft:

**A318ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/build_a318hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/build_a318hs.sh
```

**A319ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/build_a319hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/build_a319hs.sh
```

**A320ceo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/build_a320hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/build_a320hs.sh
```

**A321neo**

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/build_a321hs.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/build_a321hs.sh
```

#### 4. Installation

The package is now ready to use. Copy the folder `build_a32x/out/lvfr-horizonsim-airbus-axx` to your Community Folder in MSFS.

#### (Optional) MSFS Dev Tools Package

If you want to use the MSFS Dev Tools, run the following command after building:

PowerShell:
```shell
.\scripts\dev-env\run.cmd ./scripts/package.sh
```

Git Bash/Linux:
```shell
./scripts/dev-env/run.sh ./scripts/package.sh
```

## License

Original source code assets present in this repository are licensed under the GNU GPLv3.

Microsoft Flight Simulator © Microsoft Corporation. The Horizon Simulations LVFR Airbus was created under Microsoft's "Game Content Usage Rules" using assets from Microsoft Flight Simulator, and it is not endorsed by or affiliated with Microsoft.
