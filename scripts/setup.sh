#!/bin/bash

# Create log file and directory
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/setup_$(date +%Y%m%d_%H%M%S).log"
touch "$LOG_FILE"

# Function to log messages
log_message() {
  local level="$1"
  local message="$2"
  local log_file="${3:-/var/log/application.log}"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local formatted_message="[$timestamp] [$level] $message"

  # Print to stdout
  echo "$formatted_message"

  # Create log directory if it doesn't exist
  local log_dir=$(dirname "$log_file")
  if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir" 2>/dev/null || {
      echo "ERROR: Failed to create log directory '$log_dir'" >&2
      return 1
    }
  fi

  # Append to log file
  echo "$formatted_message" >> "$log_file" 2>/dev/null || {
    echo "ERROR: Failed to write to log file '$log_file'" >&2
    return 2
  }

  return 0
}

# Function for color output
print_color() {
  local color_code="$1"
  local message="$2"
  local log_file="${3:-/var/log/application.log}"
  local colored_message="\033[${color_code}m${message}\033[0m"

  # Print colored message to stdout
  echo -e "$colored_message"

  # Create log directory if it doesn't exist
  local log_dir=$(dirname "$log_file")
  if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir" 2>/dev/null || {
      echo "ERROR: Failed to create log directory '$log_dir'" >&2
      return 1
    }
  fi

  # Append plain (non-colored) message to log file
  # Strip color codes for log file to avoid raw escape sequences in logs
  echo "$message" >> "$log_file" 2>/dev/null || {
    echo "ERROR: Failed to write to log file '$log_file'" >&2
    return 2
  }

  return 0
}

# Color codes
RED=31
GREEN=32
YELLOW=33
BLUE=34

# Log headers
log_message "INFO" "=== Starting setup script ==="
log_message "INFO" "Log file: $LOG_FILE"

# Exit handler to provide information on failure
cleanup_on_exit() {
  if [ "$?" -ne 0 ]; then
    print_color "$RED" "==================================================="
    print_color "$RED" "SETUP FAILED! Please send the log file to developers:"
    print_color "$RED" "$LOG_FILE"
    print_color "$RED" "==================================================="
    log_message "ERROR" "Script exited with error"
  else
    print_color "$GREEN" "==================================================="
    print_color "$GREEN" "SETUP COMPLETED SUCCESSFULLY!"
    print_color "$GREEN" "==================================================="
    log_message "INFO" "Script completed successfully"
  fi
}

trap cleanup_on_exit EXIT

set -e  # Exit on errors, but we'll handle them more carefully

# Configure git for better performance
print_color "$BLUE" "Configuring git settings..."
git config --global http.postBuffer 524288000  # 500MB buffer
git config --global http.lowSpeedLimit 1000
git config --global http.lowSpeedTime 300
git config --global core.compression 0
git config --global --add safe.directory "*"
log_message "INFO" "Git configured successfully"

cd /external
log_message "INFO" "Changed directory to /external"

# Clean if requested
for arg in "$@"; do
  if [ "$arg" = "--clean" ]; then
    print_color "$YELLOW" "Removing node_modules as requested..."
    rm -rf node_modules/
    log_message "INFO" "Removed node_modules directory"
  fi
done

# Function to validate git repository completeness
validate_repo() {
  local repo_dir=$1
  local quiet=$2

  if [ "$quiet" != "quiet" ]; then
    print_color "$BLUE" "Validating repository at $repo_dir..."
  fi
  log_message "INFO" "Validating repository: $repo_dir"

  # Change to the repository directory
  cd "$repo_dir"

  # Check if this is a valid git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_color "$RED" "❌ ERROR: $repo_dir is not a valid git repository!"
    log_message "ERROR" "$repo_dir is not a valid git repository"
    cd - > /dev/null
    return 1
  fi

  # Try to get current branch and HEAD commit
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED")
  head_commit=$(git rev-parse HEAD 2>/dev/null || echo "UNKNOWN")

  if [ "$quiet" != "quiet" ]; then
    print_color "$BLUE" "Current branch: $current_branch"
    print_color "$BLUE" "HEAD commit: $head_commit"
  fi
  log_message "INFO" "Repository $repo_dir - Branch: $current_branch, Commit: $head_commit"

  # Check for any uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    print_color "$YELLOW" "⚠️ WARNING: There are uncommitted changes in the repository."
    log_message "WARN" "Uncommitted changes detected in $repo_dir"
    print_color "$BLUE" "🔄 Automatically stashing changes for safety..."
    if git stash save "Automatic stash by setup script"; then
      print_color "$GREEN" "✅ Changes stashed successfully. You can restore them later with 'git stash pop'"
      log_message "INFO" "Successfully stashed changes in $repo_dir"
    else
      print_color "$YELLOW" "⚠️ Could not stash changes, continuing anyway"
      log_message "WARN" "Failed to stash changes in $repo_dir"
    fi
  else
    if [ "$quiet" != "quiet" ]; then
      print_color "$GREEN" "✅ Repository is clean (no uncommitted changes)."
    fi
    log_message "INFO" "Repository $repo_dir is clean"
  fi

  # List the top-level directories to verify content
  if [ "$quiet" != "quiet" ]; then
    print_color "$BLUE" "Repository contents (top-level directories):"
    ls -la | grep "^d" || echo "No directories found!"
  fi

  # Check if .git directory exists and is populated
  if [ ! -d ".git" ] || [ -z "$(ls -A .git 2>/dev/null)" ]; then
    print_color "$YELLOW" "⚠️ WARNING: .git directory is missing or empty"
    log_message "WARN" "Missing or empty .git directory in $repo_dir"
    valid=false
  fi

# Check if repository branch HEAD matches remote branch HEAD
  local current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$current_branch" ]; then
    print_color "$YELLOW" "⚠️ WARNING: Detached HEAD state detected."
    log_message "WARN" "Detached HEAD state in $repo_dir"
    valid=false
  else
    local remote_branch_head=""
    remote_branch_head=$(git ls-remote origin "$current_branch" 2>/dev/null | cut -f1)

    if [ -z "$remote_branch_head" ]; then
      print_color "$YELLOW" "⚠️ WARNING: Could not fetch remote branch '$current_branch'. Branch may not exist remotely or network issue."
      log_message "WARN" "Could not fetch remote branch '$current_branch' for $repo_dir"
      valid=false
    elif [ "$head_commit" = "$remote_branch_head" ]; then
      if [ "$quiet" != "quiet" ]; then
        print_color "$GREEN" "✅ SUCCESS: Branch '$current_branch' matches remote."
      fi
      log_message "INFO" "Repository $repo_dir branch '$current_branch' matches remote"
      valid=true
    else
      print_color "$YELLOW" "⚠️ WARNING: Branch '$current_branch' ($head_commit) does not match remote ($remote_branch_head)."
      log_message "WARN" "Repository $repo_dir branch '$current_branch' mismatch with remote"
      print_color "$BLUE" "🔄 Automatically syncing with remote branch '$current_branch'..."

      if git fetch origin "$current_branch" && git reset --hard "origin/$current_branch"; then
        print_color "$GREEN" "✅ Successfully synced branch '$current_branch' with remote"
        log_message "INFO" "Successfully synced $repo_dir branch '$current_branch' with remote"
        valid=true
      else
        print_color "$YELLOW" "⚠️ Could not sync branch '$current_branch' with remote, continuing anyway"
        log_message "WARN" "Failed to sync $repo_dir branch '$current_branch' with remote"
        valid=false
      fi
    fi
  fi

  # Return to original directory
  cd - > /dev/null

  if [ "$valid" = true ]; then
    return 0
  else
    return 1
  fi
}

# Function to clone with fallback strategies
clone_with_fallback() {
  local repo_url=$1
  local target_dir=$2

  print_color "$BLUE" "Attempting to clone $repo_url to $target_dir"
  log_message "INFO" "Starting clone of $repo_url to $target_dir"

  # Remove any previous failed attempts
  if [ -d "$target_dir" ]; then
    print_color "$YELLOW" "Removing previous clone attempt..."
    rm -rf "$target_dir"
    log_message "INFO" "Removed existing directory $target_dir"
  fi

  # Try standard clone first
  print_color "$BLUE" "Trying standard clone..."
  if git clone "$repo_url" "$target_dir"; then
    print_color "$GREEN" "✅ Standard clone successful!"
    log_message "INFO" "Standard clone successful for $target_dir"
    validate_repo "$target_dir" || {
      print_color "$YELLOW" "⚠️ Validation issues after clone, will now exit..."
      log_message "WARN" "Validation issues after clone"
      return 2
    }
    return 0
  fi

  log_message "WARN" "Standard clone failed, trying alternatives"
  print_color "$YELLOW" "Standard clone failed, trying with --single-branch..."
  if git clone --single-branch "$repo_url" "$target_dir"; then
    print_color "$GREEN" "✅ Single branch clone successful!"
    log_message "INFO" "Single branch clone successful for $target_dir"
    validate_repo "$target_dir" || {
      print_color "$YELLOW" "⚠️ Validation issues after single-branch clone, will now exit..."
      return 2
    }
    return 0
  fi

  log_message "WARN" "Single branch clone failed, trying bare clone"
  print_color "$YELLOW" "Single branch clone failed, trying bare clone with manual checkout..."
  if git clone --bare "$repo_url" "${target_dir}.git"; then
    print_color "$BLUE" "Bare clone successful, creating working directory..."
    log_message "INFO" "Bare clone successful, creating working directory for $target_dir"
    mkdir -p "$target_dir"
    cd "$target_dir"
    git init
    git remote add origin "../${target_dir}.git"
    git fetch origin

    # Try to determine the correct branch from .gitmodules
    local default_branch=""

    # Check if there's a branch specified in .gitmodules
    if [ -f "../.gitmodules" ]; then
      # Get the submodule name
      submodule_name=$(basename "$target_dir")
      log_message "INFO" "Checking .gitmodules for branch of submodule: $submodule_name"

      # Try to extract the branch from .gitmodules
      submodule_branch=$(grep -A3 "submodule \"$submodule_name\"" "../.gitmodules" | grep "branch" | cut -d"=" -f2 | tr -d ' ')

      if [ -n "$submodule_branch" ]; then
        default_branch=$submodule_branch
        print_color "$BLUE" "Found branch in .gitmodules: $default_branch"
        log_message "INFO" "Found branch in .gitmodules: $default_branch"
      fi
    fi

    # If no branch was found in .gitmodules, use the remote HEAD branch
    if [ -z "$default_branch" ]; then
      default_branch=$(git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | tr -d ' ')
      print_color "$BLUE" "Using remote default branch: $default_branch"
      log_message "INFO" "Using remote default branch: $default_branch for $target_dir"
    fi

    print_color "$BLUE" "Checking out branch: $default_branch"
    log_message "INFO" "Checking out branch: $default_branch for $target_dir"

    if git checkout -f "$default_branch"; then
      print_color "$GREEN" "✅ Checkout successful!"
      log_message "INFO" "Checkout successful for $target_dir"
      cd ..
      validate_repo "$target_dir" || {
        print_color "$YELLOW" "⚠️ Validation issues after bare clone, will now exit..."
        return 2
      }
      return 0
    else
      print_color "$YELLOW" "⚠️ Checkout failed, trying to fetch all branches..."
      log_message "WARN" "Checkout failed, trying to fetch all branches for $target_dir"
      git fetch --all
      git checkout -f HEAD || git reset --hard HEAD
      cd ..
      print_color "$YELLOW" "⚠️ Repository may be incomplete but continuing..."
      log_message "WARN" "Repository $target_dir may be incomplete but continuing"
      return 1
    fi
  fi

  print_color "$RED" "❌ All clone attempts failed for $repo_url"
  log_message "ERROR" "All clone attempts failed for $repo_url to $target_dir"
  return 1
}

# Initialize main repository
print_color "$BLUE" "Initializing flybywire submodule..."
log_message "INFO" "Initializing flybywire submodule"

if git submodule update --init flybywire; then
  print_color "$GREEN" "✅ Flybywire submodule initialized successfully!"
  log_message "INFO" "Flybywire submodule initialized successfully"
else
  print_color "$YELLOW" "⚠️ Could not initialize flybywire submodule normally, trying alternatives..."
  log_message "WARN" "Failed to initialize flybywire submodule, trying alternatives"

  # Try to repair the .git/modules directory
  print_color "$BLUE" "Checking if modules directory exists..."
  if [ ! -d ".git/modules/flybywire" ]; then
    print_color "$YELLOW" "⚠️ Missing submodule directory. Attempting manual clone..."

    # Try to get the URL and branch from .gitmodules
    local flybywire_url=$(git config -f .gitmodules --get submodule.flybywire.url 2>/dev/null || echo "")
    local flybywire_branch=$(git config -f .gitmodules --get submodule.flybywire.branch 2>/dev/null || echo "")

    if [ -z "$flybywire_url" ]; then
      print_color "$YELLOW" "⚠️ Could not find flybywire URL in .gitmodules, using default"
      log_message "WARN" "Could not find flybywire URL in .gitmodules"
      flybywire_url="https://github.com/flybywiresim/a32nx.git" # Default fallback URL
    fi

    if [ -n "$flybywire_branch" ]; then
      print_color "$BLUE" "Found branch for flybywire in .gitmodules: $flybywire_branch"
      log_message "INFO" "Found branch for flybywire in .gitmodules: $flybywire_branch"
    else
      print_color "$YELLOW" "⚠️ No branch specified for flybywire in .gitmodules"
      log_message "WARN" "No branch specified for flybywire in .gitmodules"
    fi

    print_color "$BLUE" "Attempting to clone flybywire from $flybywire_url"
    log_message "INFO" "Attempting to clone flybywire from $flybywire_url"

    if [ -d "flybywire" ]; then
      print_color "$YELLOW" "⚠️ Removing existing flybywire directory..."
      rm -rf flybywire
      log_message "INFO" "Removed existing flybywire directory"
    fi

    clone_with_fallback "$flybywire_url" "flybywire"

    # If clone successful and we have a branch specified, make sure to check it out
    if [ -d "flybywire" ] && [ -n "$flybywire_branch" ]; then
      print_color "$BLUE" "Checking out specified branch: $flybywire_branch"
      log_message "INFO" "Checking out specified branch: $flybywire_branch for flybywire"
      (cd flybywire && git checkout "$flybywire_branch") || {
        print_color "$YELLOW" "⚠️ Could not checkout branch $flybywire_branch"
        log_message "WARN" "Could not checkout branch $flybywire_branch for flybywire"
      }
    fi
  fi
fi

if ! validate_repo "flybywire" quiet; then
  print_color "$YELLOW" "⚠️ WARNING: flybywire repository validation issues detected."
  print_color "$BLUE" "🔄 Attempting to fix flybywire repository..."
  log_message "WARN" "Flybywire repository validation issues detected, attempting fix"
else
  print_color "$GREEN" "✅ Flybywire repository validated successfully!"
  log_message "INFO" "Flybywire repository validated successfully"
fi

# Initialize large-files submodule
print_color "$BLUE" "Initializing large-files submodule..."
log_message "INFO" "Initializing large-files submodule"
cd flybywire

if [ ! -d "large-files" ] || [ -z "$(ls -A large-files 2>/dev/null)" ]; then
  LARGE_FILES_URL=$(git config -f .gitmodules --get submodule.large-files.url 2>/dev/null || echo "https://github.com/flybywiresim/aircraft-large-files")
  LARGE_FILES_BRANCH=$(git config -f .gitmodules --get submodule.large-files.branch 2>/dev/null || echo "")

  print_color "$BLUE" "Cloning large-files from $LARGE_FILES_URL"
  log_message "INFO" "Cloning large-files from $LARGE_FILES_URL"

  if [ -n "$LARGE_FILES_BRANCH" ]; then
    print_color "$BLUE" "Will use branch: $LARGE_FILES_BRANCH (from .gitmodules)"
    log_message "INFO" "Will use branch: $LARGE_FILES_BRANCH for large-files"
  fi

  clone_with_fallback "$LARGE_FILES_URL" "large-files"

  # If clone successful and we have a branch specified, make sure to check it out
  if [ -d "large-files" ] && [ -n "$LARGE_FILES_BRANCH" ]; then
    print_color "$BLUE" "Checking out specified branch: $LARGE_FILES_BRANCH"
    log_message "INFO" "Checking out specified branch: $LARGE_FILES_BRANCH for large-files"
    (cd large-files && git checkout "$LARGE_FILES_BRANCH") || {
      print_color "$YELLOW" "⚠️ Could not checkout branch $LARGE_FILES_BRANCH, will use default branch"
      log_message "WARN" "Could not checkout branch $LARGE_FILES_BRANCH for large-files"
    }
  fi

  # If we have a successful clone, register it as a submodule
  if [ -d "large-files" ] && [ -n "$(ls -A large-files 2>/dev/null)" ]; then
    print_color "$BLUE" "Registering large-files as submodule..."
    log_message "INFO" "Registering large-files as submodule"
    if git submodule update --init large-files; then
      print_color "$GREEN" "✅ Large-files submodule registered successfully!"
      log_message "INFO" "Large-files submodule registered successfully"
    else
      print_color "$YELLOW" "⚠️ Submodule registration warning - continuing anyway"
      log_message "WARN" "Submodule registration warning for large-files"
    fi
  fi
else
  print_color "$GREEN" "✅ large-files directory already exists and has content"
  log_message "INFO" "large-files directory already exists and has content"
  if ! validate_repo "large-files" quiet; then
    print_color "$YELLOW" "⚠️ ISSUE DETECTED: large-files repository appears to be incomplete!"
    log_message "WARN" "large-files repository appears to be incomplete, will now exit"
    exit 2
  else
    print_color "$GREEN" "✅ large-files repository validated successfully!"
    log_message "INFO" "large-files repository validated successfully"
  fi
fi

cd /external
log_message "INFO" "Changed directory back to /external"

# Continue with package installation
print_color "$BLUE" "Installing packages..."
log_message "INFO" "Starting package installation"

# Uninstall existing pnpm
print_color "$BLUE" "Uninstalling existing pnpm..."
log_message "INFO" "Uninstalling existing pnpm"
if npm uninstall -g pnpm; then
  print_color "$GREEN" "✅ Successfully uninstalled existing pnpm"
  log_message "INFO" "Successfully uninstalled existing pnpm"
else
  print_color "$YELLOW" "⚠️ No existing pnpm installation found or couldn't uninstall, continuing..."
  log_message "WARN" "No existing pnpm installation found or couldn't uninstall"
fi

# Install latest pnpm
print_color "$BLUE" "Installing pnpm@latest-10..."
log_message "INFO" "Installing pnpm@latest-10"
if npm install -g pnpm@latest-10; then
  print_color "$GREEN" "✅ Successfully installed pnpm"
  log_message "INFO" "Successfully installed pnpm"
else
  print_color "$RED" "❌ Failed to install pnpm. This is critical for the build!"
  log_message "ERROR" "Failed to install pnpm"
  print_color "$YELLOW" "Retrying with npm cache clear..."
  log_message "INFO" "Retrying pnpm installation with npm cache clear"

  npm cache clean --force
  if npm install -g pnpm@latest-10; then
    print_color "$GREEN" "✅ Successfully installed pnpm after cache clear"
    log_message "INFO" "Successfully installed pnpm after cache clear"
  else
    print_color "$RED" "❌ CRITICAL ERROR: Failed to install pnpm after retrying!"
    log_message "ERROR" "CRITICAL: Failed to install pnpm after retrying"
    exit 1
  fi
fi

# Fix permissions on node_modules
print_color "$BLUE" "Fixing permissions on node_modules..."
log_message "INFO" "Fixing permissions on node_modules"

if [ -d "/external/node_modules" ]; then
  # Get current owner
  current_owner=$(stat -c '%U' /external/node_modules 2>/dev/null)
  current_user=$(whoami)

  print_color "$BLUE" "Current owner: $current_owner, Current user: $current_user"
  log_message "INFO" "Current owner of node_modules: $current_owner, Current user: $current_user"

  if [ "$current_owner" != "$current_user" ]; then
    print_color "$BLUE" "Attempting to change ownership..."
    log_message "INFO" "Attempting to change ownership of node_modules"

    if chown -R $(whoami) /external/node_modules 2>/dev/null; then
      print_color "$GREEN" "✅ Successfully changed ownership of node_modules"
      log_message "INFO" "Successfully changed ownership of node_modules"
    else
      print_color "$YELLOW" "⚠️ Could not change ownership, attempting chmod as fallback..."
      log_message "WARN" "Could not change ownership, attempting chmod as fallback"

      if chmod -R 777 /external/node_modules 2>/dev/null; then
        print_color "$GREEN" "✅ Successfully set permissions on node_modules with chmod"
        log_message "INFO" "Successfully set permissions on node_modules with chmod"
      else
        print_color "$YELLOW" "⚠️ Permission fix attempts failed, continuing anyway..."
        print_color "$YELLOW" "This might cause issues during package installation"
        log_message "WARN" "Permission fix attempts failed, this might cause issues"
      fi
    fi
  else
    print_color "$GREEN" "✅ Current user $current_user is already the owner of /external/node_modules, skipping permissions change"
    log_message "INFO" "Current user is already the owner of node_modules"
  fi
else
  print_color "$BLUE" "node_modules directory doesn't exist yet, will be created during installation"
  log_message "INFO" "node_modules directory doesn't exist yet"
fi

# Install packages with pnpm
print_color "$BLUE" "Installing packages with pnpm..."
log_message "INFO" "Installing packages with pnpm"

# Retry mechanism for pnpm installation
max_retries=3
retry_count=0
success=false

while [ $retry_count -lt $max_retries ] && [ "$success" = "false" ]; do
  retry_count=$((retry_count + 1))

  if [ $retry_count -gt 1 ]; then
    print_color "$YELLOW" "⚠️ Retry $retry_count of $max_retries for package installation"
    log_message "WARN" "Retry $retry_count of $max_retries for package installation"
  fi

  if pnpm i; then
    print_color "$GREEN" "✅ Package installation successful!"
    log_message "INFO" "Package installation successful"
    success=true
  else
    if [ $retry_count -lt $max_retries ]; then
      print_color "$YELLOW" "⚠️ Package installation failed, trying to fix..."
      log_message "WARN" "Package installation failed, attempting fix before retry"

      # Clear caches and try to fix common issues
      print_color "$BLUE" "Clearing pnpm cache..."
      pnpm store prune || true

      print_color "$BLUE" "Checking for package-lock.json..."
      if [ -f "package-lock.json" ]; then
        print_color "$BLUE" "Removing package-lock.json..."
        rm package-lock.json
        log_message "INFO" "Removed package-lock.json"
      fi

      print_color "$BLUE" "Checking for pnpm-lock.yaml..."
      if [ -f "pnpm-lock.yaml" ]; then
        print_color "$BLUE" "Removing pnpm-lock.yaml..."
        rm pnpm-lock.yaml
        log_message "INFO" "Removed pnpm-lock.yaml"
      fi

      # If node_modules exists and third retry, try removing it
      if [ $retry_count -eq 2 ] && [ -d "node_modules" ]; then
        print_color "$YELLOW" "⚠️ Last retry failed, removing node_modules and trying again..."
        rm -rf node_modules
        log_message "INFO" "Removed node_modules for clean retry"
      fi
    else
      print_color "$RED" "❌ Package installation failed after $max_retries attempts!"
      log_message "ERROR" "Package installation failed after $max_retries attempts"
    fi
  fi
done

if [ "$success" = "true" ]; then
  print_color "$GREEN" "==================================================="
  print_color "$GREEN" "🎉 Setup completed successfully! 🎉"
  print_color "$GREEN" "==================================================="
  log_message "INFO" "=== Setup completed successfully ==="
else
  print_color "$RED" "==================================================="
  print_color "$RED" "❌ Setup failed after multiple attempts! ❌"
  print_color "$RED" "Please send the log file to developers:"
  print_color "$RED" "$LOG_FILE"
  print_color "$RED" "==================================================="
  log_message "ERROR" "=== Setup failed after multiple attempts ==="
  exit 1
fi
