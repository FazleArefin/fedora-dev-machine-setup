# fedora-dev-machine-setup | Fedora Workstation 43

## Description

This repo contains Ansible playbooks to configure your system as a development machine after a clean install.

The playbooks have been tested on:

- **Fedora Workstation 43**

---

## What gets installed and configured?

I am a DevSecOps Engineer, and my daily job includes working with AWS, Docker, Ansible, Terraform, etc. If you're in a similar profession, the installed system will suit your needs. It is also easy to extend using Ansible roles.

Summary of packages that get installed and configured based on roles:

- **role: harden_system**
  - Remove the `passim` package and stop the `passimd` service from listening on 0.0.0.0
  - Disable Link-Local Multicast Name Resolution (LLMNR) listening on 0.0.0.0
  - Create and activate a new `firewalld` zone `FedoraWsHardened`, which DROPS all incoming requests

- **role: base**
  - Set the default system editor to Vim instead of Nano
  - Enable the `firewalld` firewall
  - Tune system swappiness to greatly reduce swapping
  - Upgrade all packages
  - Install archiving tools like zip, rar, etc.
  - Install LibreOffice
  - Install Foliate, an e-book reader
  - Install Obsidian markdown editor
  - Install power management tools like [TLP](https://github.com/linrunner/TLP)
  - Install development tools like android-tools, awscli, httpie, clusterssh, Docker, FileZilla, Golang, Poetry, etc.
  - Install code formatters and linters like Black, Ruff, ansible-lint, etc.
  - Set up Golang directories
  - Install download tools like Axel, Transmission, Wget, Aria2
  - Install image, audio, and video tools like VLC, Totem, GIMP, ImageMagick, etc.
  - Install and configure an SSH server if not set to `laptop_mode`
  - Option to turn on Night Light for eye comfort (set `base_permanent_night_light.night_light_enabled` to `True`)
  - Enable `fzf` fuzzy finder in the Zsh terminal
  - Install [lazygit](https://github.com/jesseduffield/lazygit)
  - Install terminal emulator Alacritty
  - Set GNOME color-scheme to dark mode

- **role: zsh**
  - Install the Zsh package and set the user shell to Zsh
  - Install Antigen Zsh plugin manager
  - Copy and enable a sample `~/.zshrc` file if one doesn't exist
    - Includes a function to stop `ssh-agent` from repeatedly asking for encrypted SSH key passwords in new terminals
    - Adds additional aliases and functions in `~/.shell_aliases` and `~/.shell_functions`
  - Install ohmyzsh/ohmyzsh and enable bundled plugins
  - Enable the Bullet Train Zsh theme (others like p10k can be configured as well)

- **role: terminal_customizations**
  - Download and install Nerd Fonts from ryanoasis/nerd-fonts; ideal for terminal and programming editors
  - Copy and enable a sample Tilix config file with configured Nerd Font
  - Copy and enable a sample Tmux config file if one doesn't exist
  - Copy and enable `~/.tmux.conf` with [tmux plugin manager](https://github.com/tmux-plugins/tpm) and several plugins
    - Open Tilix and run the `tmux` command, or enable a custom command option in Tilix
    - Edit `~/.tmux.conf` as needed

- **role: neovim**
  - Install Neovim packages
  - Install [LazyVim](https://www.lazyvim.org) Neovim distribution
    - Open `nvim` from terminal; plugins will install automatically on first launch

- **role: vscode**
  - Add the Visual Studio Code APT repo
  - Install Visual Studio Code
  - Install popular extensions

- **role: privacy**
  - Install Tor
  - Configure Tor to run at boot and avoid certain countries as exit nodes
    - Edit `/etc/tor/torrc` if needed
  - Install ProxyChains
  - Configure ProxyChains to use Tor. See [my Medium story](https://fazlearefin.medium.com/tunneling-traffic-over-tor-network-using-proxychains-34c77ec32c0f) for usage
    - Edit `/etc/proxychains.conf` if needed
  - Install a metadata anonymization toolkit

- **role: security**
  - Install ClamAV (antivirus) and its GNOME interface. Run scans manually via Nautilus or CLI using `clamscan`; `clamd` is not installed due to high memory usage
  - Install Firejail for sandboxing applications

- **role: virtualization**
  - Install Docker packages
  - Install VirtualBox packages

- **role: googlechrome**
  - Add the Google Chrome APT repo
  - Install Google Chrome

---

## Step 0 | Prerequisites for running the Ansible playbooks

On the system you are about to configure using Ansible, perform the following:

Install `ansible` and `git` first:

```bash
/usr/bin/sudo dnf update -y
/usr/bin/sudo dnf install ansible git -y
```

```bash
git clone https://github.com/fazlearefin/fedora-dev-machine-setup.git
cd fedora-dev-machine-setup
```

## Step 1 | Running the playbooks to configure your system

**Run the following as yourself (the primary user), not as `root`:**

```bash
ansible-playbook main.yml -vv -e "{ laptop_mode: True }" -e "local_username=$(id -un)" -K
```

Enter your sudo password when prompted for `BECOME password:`.

The `main.yml` playbook can take between 15 minutes to an hour to finish.

Once complete, reboot your laptop for all changes to take effect.

> ### What is `laptop_mode`?

#### When set to `True`

- Installs packages like [TLP](https://github.com/linrunner/TLP) for battery optimization

#### When set to `False`

- Skips installing battery-saving packages like [TLP](https://github.com/linrunner/TLP)

---

## Known Issues

- If the Ansible playbook stops mid-way, rerun it. Most tasks are idempotent, so re-execution is safe.
- If your terminal displays strange characters after installing a Zsh theme, change the font to a Nerd Font in the terminal's settings.
- If you dislike fuzzy finder completions, comment out the `#fzf` lines in your `~/.zshrc` (this is a feature, not a bug).
- Some [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) plugins like `docker` may cause an error such as `tee: <snip> No such file or directory` when launching the terminal. Fix this by running: `mkdir -p ~/.antigen/bundles/robbyrussell/oh-my-zsh/cache/completions`.

---

## Pull Requests and Forks

Pull requests are welcome! However, this repo is tailored to my own development needs. For your own workflow, it's probably better to fork it and customize as you like.

---

## Donations

If this setup saved you time or effort, feel free to donate—though the repo is entirely free and open, with no strings attached.

Bitcoin (BTC): `bc1qzlhpm94vtk2ht67etdutzcy2g5an5v6g36tp0m`
