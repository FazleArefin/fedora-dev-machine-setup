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
    local rt="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR not set}"
    local wl="${WAYLAND_DISPLAY:-wayland-0}"
    local home="${HOME:?HOME not set}"
    local wl_src resolv_target
    local d p
    local -a args=()
    local -a parents=()
    local -A seen=()

    # Resolve Wayland socket
    if [[ "$wl" = /* ]]; then
        wl_src="$wl"
    else
        wl_src="$rt/$wl"
    fi

    if [[ ! -S "$wl_src" ]]; then
        echo "Error: Wayland socket not found: $wl_src" >&2
        return 1
    fi

    # Resolve DNS configuration
    resolv_target="$(readlink -f /etc/resolv.conf 2>/dev/null || true)"

    # Add parent directories required for mount destinations
    add_parents() {
        p="${1%/*}"
        parents=()

        while [[ -n "$p" && "$p" != "/" ]]; do
            parents=("$p" "${parents[@]}")
            p="${p%/*}"
        done

        for d in "${parents[@]}"; do
            if [[ -z "${seen[$d]+x}" ]]; then
                args+=(--dir "$d")
                seen["$d"]=1
            fi
        done
    }

    # Namespace isolation and privilege restrictions
    args+=(
        --unshare-all
        --share-net
        --die-with-parent
        --new-session
        --cap-drop ALL
        --clearenv
    )

    # Read-only system filesystem
    args+=(
        --ro-bind /usr /usr
        --symlink usr/bin /bin
        --symlink usr/sbin /sbin
        --symlink usr/lib /lib
        --symlink usr/lib64 /lib64
        --ro-bind /etc /etc
    )

    # DNS target: create missing mount-point parents first
    if [[ -n "$resolv_target" &&
            "$resolv_target" != "/etc/resolv.conf" &&
            -f "$resolv_target" ]]; then
        add_parents "$resolv_target"
        args+=(--ro-bind "$resolv_target" "$resolv_target")
    fi

    # Process, devices and temporary filesystem
    args+=(
        --proc /proc
        --dev /dev
        --tmpfs /tmp
    )

    # Disposable home directory
    add_parents "$home"
    args+=(
        --tmpfs "$home"
        --dir "$home/.cache"
        --dir "$home/.mozilla"
    )

    # Isolated runtime directory
    add_parents "$rt"
    args+=(
        --perms 0700
        --dir "$rt"
        --bind "$wl_src" "$rt/wayland-0"
    )

    # Environment
    args+=(
        --setenv HOME "$home"
        --setenv PATH /usr/bin
        --setenv XDG_RUNTIME_DIR "$rt"
        --setenv WAYLAND_DISPLAY wayland-0
        --setenv MOZ_ENABLE_WAYLAND 1
        --setenv LANG "${LANG:-C.UTF-8}"
        --setenv TMPDIR /tmp
    )

    # Optional audio
    # args+=(--bind-try "$rt/pulse/native" "$rt/pulse/native")

    # Optional GPU acceleration
    # args+=(--dev-bind-try /dev/dri /dev/dri)

    bwrap "${args[@]}" \
        /usr/bin/firefox \
        --new-instance \
        --no-remote \
        --safe-mode \
        --private-window \
        "$@"
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
