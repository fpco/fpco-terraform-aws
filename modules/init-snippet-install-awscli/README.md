## Init Snippet: Install AWS CLI Tool

Generate an init snippet to install the AWS cli tool on boot. This will:

* use apt (by default) to install `python-pip`
* use `pip` to upgrade `pip`
* us `pip` to install `awscli`

To override package manager set a proper value to the argument `install_cmd`.
