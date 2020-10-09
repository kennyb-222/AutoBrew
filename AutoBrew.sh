#!/bin/sh
# AutoBrew - Install Homebrew with root
# Source: https://github.com/kennyb-222/AutoBrew/
# Author: Kenny Botelho
# Version: 1.0

# Set environment variables
export HOME=$(mktemp -d)
export USER=root
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
BREW_INSTALL_LOG=$(mktemp)

# Get current logged in user
TargetUser=$(echo "show State:/Users/ConsoleUser" | \
    scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if parameter passed to use pre-defined user
if [[ -n $3 ]]; then
    # Supporting running the script in Jamf with no specialization via Self Service
    TargetUser=$3
elif [[ -n $1 ]]; then
    # Fallback case for the command line initiated method
    TargetUser=$3
fi

# Ensure TargetUser isn't empty
if [ -z "$TargetUser" ]; then
    /bin/echo "'TargetUser' is empty. You must specify a user!"
    exit 1
fi

# Verify the TargetUser is valid. In some cases, user may be provisioned
# (created with something like sysadminctl) but not fully created.
# A 'dscl . list' will reveal all users, including those provisioned, while a
# 'dscl . read' will only return an exit code of 0 if the user is created & valid.
# A provisioned user will cause 'su - "${TargetUser}" -c "<install brew cmd>"' to fail,
# but chown will happily set the desired provisioned user ownership.
VALID_USER=$(/usr/bin/dscl . read /Users/${TargetUser})
exitcode=$(/bin/echo $?)

if [ "$exitcode" != 0 ]; then
    /bin/echo "Specified user - ${TargetUser} - is invalid. This could be because"
    /bin/echo "the user doesn't exist or was only provisioned with a tool like"
    /bin/echo "'sysadminctl', and not fully created."
    exit 1
fi

# Install Homebrew | strip out all interactive prompts
/bin/bash -c "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install.sh | \
    sed "s/abort \"Don't run this as root\!\"/\
    echo \"WARNING: Running as root...\"/" | \
    sed 's/  wait_for_user/  :/')" 2>&1 | tee ${BREW_INSTALL_LOG}

# Reset Homebrew permissions for target user
brew_file_paths=$(sed '1,/==> This script will install:/d;/==> /,$d' \
    ${BREW_INSTALL_LOG})
brew_dir_paths=$(sed '1,/==> The following new directories/d;/==> /,$d' \
    ${BREW_INSTALL_LOG})
chown -R "${TargetUser}":admin ${brew_file_paths} ${brew_dir_paths}
chgrp admin /usr/local/bin/
chmod g+w /usr/local/bin

# Unset home/user environment variables
unset HOME
unset USER

# Finish up Homebrew install as target user
su - "${TargetUser}" -c "/usr/local/bin/brew update --force"

# Run cleanup before checking in with the doctor
su - "${TargetUser}" -c "/usr/local/bin/brew cleanup"

# Check Homebrew install status
su - "${TargetUser}" -c "/usr/local/bin/brew doctor"

# Check with the doctor status to see if everything looks good
if [[ $? -eq 0 ]]; then
    echo 'Homebrew Installation Complete! Your system is ready to brew.'
    exit 0
else
    echo 'AutoBrew Installation Failed'
    exit 1
fi
