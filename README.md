# tmux-install
Script for installing tmux versions and dependencies for different Linux distributions.

It's assumed that wget and a C/C++ compiler are installed.

```
usage: tmux-install [-h] [--version {2.9a,3.0-rc5,3.0,3.0a}]
                    [--install-dir INSTALL_DIR]

optional arguments:
  -h, --help            show this help message and exit
  --version {2.9a,3.0-rc5,3.0,3.0a}
                        Set the tmux version to install. Default: latest
  --install-dir INSTALL_DIR
                        Set the install dir. Default: /home/savio/tmux-static
```