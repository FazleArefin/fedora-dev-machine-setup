# .shell_functions.sh - Custom shell functions for convenience and system management

# Check if the shell is interactive
[[ $- != *i* ]] && return

function update_fedora {
    echo "Updating Fedora system..."
    /usr/bin/sudo dnf -y upgrade --refresh
    /usr/bin/sudo dnf distro-sync -y
    /usr/bin/sudo dnf autoremove -y
    /usr/bin/sudo dnf clean all
    /usr/bin/sudo flatpak update -y
    echo "Update complete!"
}

# a locked-down firefox instance running inside a sandbox
function safefox {
    /usr/bin/firejail --name=safe-firefox --seccomp --private --private-dev --private-tmp --protocol=inet firefox --new-instance --no-remote --safe-mode --private-window $1
}

# update existing docker images
function update_docker_images {
    docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | sort -u | xargs --no-run-if-empty -L1 docker pull
    # cleanup images containing no tags; usually the ones which get updated
    if nonetags=$(docker images | grep "<none>"); then awk '{ print $3 }' <<< "$nonetags" | xargs --no-run-if-empty -L1 docker rmi -f; fi
}

### BEGIN night light control ###
function night_light_enable {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
}

function night_light_disable {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false
}

function night_light_low {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4700
}

function night_light_medium {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4200
}

function night_light_high {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3700
}
### END night light control ###

# update all cargo-installed packages
function update_cargo_packages {
    if ! command -v cargo-install-update &>/dev/null; then
        cargo install cargo-update
    fi
    cargo install-update --all
}
