# Full system configuration
Almost everything needed for the system is (or at least should be)
included into Nix flake.

But there are things like manual installations, downloads (at least, need to install Nix).
Some of them are automated in `./setup.sh`, others are described here.

## On a fresh Mac
### Run setup script
```bash
curl -L https://bit.ly/new_mac_setup | bash
```
It will setup git, install Nix, clone this repo, install and configure everything from the flake.

### Install UI apps manually
- Setup Karabiner elements. Copy settings from this repo.
- [Download](https://arc.net/download) and install Arc browser. *Login with personal default account.*
- [Download](https://app.grammarly.com/apps) and install Grammarly. Login in web and go via the link to download Desktop app.
- [ ] Think about passwords backup or Arc replacements.
- [ ] More commands for creating tmux sessions.
- Signal, Whatsapp

### Setup for Mate academy work
- Install AWS VPN Client and login to password manager using [this guide (ClickUp)](https://app.clickup.com/24383048/v/dc/q83j8-12520/q83j8-335907).
- Run `npm login`. Use shared password.
- [ ] aws cli setup
- [ ] kubectl cli login
- Clone website `mkdir ~/mate && cd mate && git clone website`.
- Log in into Slack using old email y.holiuk@mate.academy.
- Log in into Figma using shared account. Login with personal on the web.