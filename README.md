# AutoBrew

AutoBrew.sh makes Homebrew deployments simple, easy, and automated. 

## How to install Homebrew using AutoBrew.sh
Simply run this script using your favorite management tool such as Jamf Pro or Munki to install Homebrew as the currently logged in user:

`sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kennyb-222/AutoBrew/master/AutoBrew.sh)"`

You can also run this script to install homebrew for any predefined user:

`sudo /bin/sh /path/to/AutoBrew.sh "username"`
