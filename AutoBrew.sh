#!/bin/sh
# AutoBrew - Install Homebrew with root
# Author: Kenny Botelho
# Version: 1.0

# Set environment variables
export HOME=$(mktemp -d)
export USER=root
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Get current logged in user
ConsoleUser=$(echo "show State:/Users/ConsoleUser" | \
    scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if parameter passed to use pre-defined user
if [[ -n $3 ]]; then
    # Supporting running the script in Jamf with no specialization via Self Service
    ConsoleUser=$3
elif [[ -n $1 ]]; then
    # Fallback case for the command line initiated method
    ConsoleUser=$3
fi

# Install Homebrew | strip out all interactive prompts
/bin/bash -c "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install.sh | \
    sed "s/abort \"Don't run this as root\!\"/\
    echo \"WARNING: Running as root...\"/" | \
    sed 's/  wait_for_user/  :/')"

# Reset /usr/local permissions for current user
chown -R "${ConsoleUser}":admin /usr/local && \
    chmod -R g+rwx /usr/local

# Unset home/user environment variables
unset HOME
unset USER

# Finish up Homebrew install as logged in user
sudo -u "${ConsoleUser}" bash -c "/usr/local/bin/brew update --force"

# Run cleanup before checking in with the doctor
sudo -u "${ConsoleUser}" bash -c "/usr/local/bin/brew cleanup"

# Check Homebrew install status
sudo -u "${ConsoleUser}" bash -c "/usr/local/bin/brew doctor"

# Check with the doctor status to see if everything looks good
if [[ $? -eq 0 ]]; then
    echo 'Homebrew Installation Complete! Your system is ready to brew.'
    exit 0
else
    echo 'AutoBrew Installation Failed'
    exit 1
fi
