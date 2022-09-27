# Bitwarden CLI functions
## Rationale
The idea was to move from the bitwarden browser extension to its command line interface (CLI). Thankfully they provide one. However, the speed to login into website decreases when a password has to be copied&pasted by hand (CLI). Compared to only hitting a shortcut in the browser to fill out a login form (with the browser extension), this is quite slow. So I wanted a shell where I can lookup passwords fast and a directly copied into my clipboard.

## Usage
I have made a startup program popping a zsh shell with the sourced `rc-file`. Like this:
```bash
#!/usr/bin/zsh

ZDOTDIR=<script_folder> BW_EMAIL=<my_bitwarden_email> zsh
```

or source the file directly in any shell

```bash
source .zshrc
```
