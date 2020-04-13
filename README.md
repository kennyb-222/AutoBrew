# AutoBrew

AutoBrew.sh makes automated Homebrew deployment simple and easy. 

## How to install Homebrew using AutoBrew.sh
Simply run this script using your favorite management tool such as Jamf Pro or Munki to install Homebrew as the currently logged in user.

`sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kennyb-222/AutoBrew/master/AutoBrew.sh)"`

You can also run this script to install homebrew for any user on the system
`/bin/sh /path/to/AutoBrew.sh "username"`
