# AutoBrew

AutoBrew.sh makes Homebrew deployments simple, easy, and automated.

##### Disclaimer
"Running/Installing Homebrew as root is extremely dangerous and no longer supported using the official Homebrew installation method."

### How to install Homebrew using AutoBrew.sh
Simply run this script using your favorite management tool such as Jamf Pro or Munki to install Homebrew as the currently logged in user, or you can run the script directly from the command line as follows:

`sudo /bin/sh /path/to/AutoBrew.sh`

You can also run this script with an argument containing the username to install homebrew for any predefined user:

`sudo /bin/sh /path/to/AutoBrew.sh "username"`



##### Notes
This has only been tested on macOS Catalina 10.15
