#!/usr/bin/env bash
# Run individual stages on the target laptop; no installation happens by default.
set -euo pipefail
umask 077

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
identity_file="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/key.txt"

die() { printf '%s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || die "Commande manquante : $1"; }
target_only() {
    [[ $EUID -ne 0 ]] || die 'Lancer ce script avec ton utilisateur, pas avec sudo.'
    [[ -f /etc/os-release ]] || die 'CachyOS requis.'
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ ${ID:-} == cachyos ]] || die 'Les étapes d’installation sont réservées à CachyOS.'
}
# Chezmoi must see the same mask as ordinary interactive invocations. Secret
# targets use private_ attributes; backups and the age identity stay private.
cm() { (umask 022; chezmoi --source "$repo_dir" --config "$config_file" "$@"); }
package_list() { sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$1"; }

install_packages() {
    target_only
    need pacman
    local -a packages
    mapfile -t packages < <(package_list "$repo_dir/packages/pacman.txt")
    # A complete upgrade avoids partial upgrades on Arch/CachyOS.
    sudo pacman -Syu --needed "${packages[@]}"
    if pacman -Si zen-browser >/dev/null 2>&1; then
        sudo pacman -S --needed zen-browser
    elif pacman -Si zen-browser-bin >/dev/null 2>&1; then
        sudo pacman -S --needed zen-browser-bin
    elif command -v paru >/dev/null; then
        mapfile -t packages < <(package_list "$repo_dir/packages/aur.txt")
        paru -S --needed "${packages[@]}"
    else
        die 'Installer zen-browser-bin via l’AUR (ou installer paru), puis relancer cette étape.'
    fi
}

install_runtime() {
    target_only
    need git
    export NVM_DIR="$HOME/.nvm"
    if [[ ! -s $NVM_DIR/nvm.sh ]]; then
        [[ ! -e $NVM_DIR ]] || die "$NVM_DIR existe mais ne contient pas nvm.sh."
        git clone --branch v0.40.8 --depth 1 https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    fi
    # nvm is intended to be sourced and is not nounset-safe on all versions.
    set +u
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm alias default 'lts/*'
    nvm use default
    set -u
    # No legacy globals, Bun, Yarn or other Node versions are copied.
    npm install --global pnpm @openai/codex
    node --version
    pnpm --version
    codex --version
    printf 'Versions NVM présentes (sur un laptop neuf : une seule LTS) :\n'
    find "$NVM_DIR/versions/node" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
}

init_config() {
    target_only
    need chezmoi
    mkdir -p -- "$(dirname -- "$config_file")"
    # Init writes only the chezmoi configuration, without applying dotfiles.
    cm init
    if [[ ! -s $identity_file ]]; then
        need age
        local temporary_identity
        temporary_identity=$(mktemp "$(dirname -- "$identity_file")/.age-key.XXXXXX")
        if age --decrypt --output "$temporary_identity" "$repo_dir/key.txt.age"; then
            chmod 600 "$temporary_identity"
            mv -- "$temporary_identity" "$identity_file"
        else
            rm -f -- "$temporary_identity"
            die 'Déchiffrement de la clé age échoué ; aucun dotfile appliqué.'
        fi
    fi
    printf 'Configuration Chezmoi initialisée ; aucun dotfile appliqué.\n'
}

install_gisland() {
    target_only
    need git
    need cmake
    # shellcheck source=../vendor/gisland.env
    source "$repo_dir/vendor/gisland.env"
    local source_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/gisland-$GISLAND_REVISION"
    if [[ ! -d $source_dir ]]; then
        mkdir -p -- "$(dirname -- "$source_dir")"
        # Public HTTPS works before the SSH keys have been restored.
        git clone --no-checkout https://github.com/gregory-artaud/gisland.git "$source_dir"
        git -C "$source_dir" checkout --detach "$GISLAND_BASE"
        git -C "$source_dir" apply --index "$repo_dir/vendor/gisland.patch"
    fi
    [[ $(git -C "$source_dir" write-tree) == "$GISLAND_TREE" ]] || \
        die "Sources Gisland inattendues dans $source_dir ; vérifier ce checkout."
    git -C "$source_dir" diff --quiet || die 'Sources Gisland modifiées depuis leur préparation.'
    (
        cd -- "$source_dir"
        cmake --preset release -DCMAKE_INSTALL_PREFIX="$HOME/.local"
        cmake --build --preset release --parallel "${DOTFILES_BUILD_JOBS:-2}"
        # Stage binaries/resources/service only. Start it later from i3.
        cmake --install build/release
    )
    printf 'Gisland construit et installé ; service non démarré.\n'
}

apply_config() {
    target_only
    [[ -s $identity_file ]] || die 'Lancer init avant apply pour restaurer la clé age.'
    # Back up exactly the managed paths that already exist, including removals.
    python3 "$repo_dir/scripts/backup.py" "$repo_dir" "$config_file"
    cm apply
    printf 'Dotfiles appliqués. Les services seront activés séparément.\n'
}

enable_services() {
    target_only
    [[ -x $HOME/.local/bin/gisland ]] || die 'Lancer gisland avant services.'
    [[ -f $HOME/.config/systemd/user/dotfiles-ssh-agent.service ]] || die 'Lancer apply avant services.'
    systemctl --user daemon-reload
    systemctl --user enable --now dotfiles-ssh-agent.service
    # i3 imports DISPLAY/XAUTHORITY and starts Gisland after login.
    systemctl --user enable gisland.service
    sudo systemctl enable --now NetworkManager.service docker.service
    # A group change takes effect after logout/login.
    sudo usermod --append --groups docker "$(id -un)"
    if [[ $(getent passwd "$(id -un)" | cut -d: -f7) != /usr/bin/zsh ]]; then
        chsh -s /usr/bin/zsh
    fi
    local desktop_file desktop_id
    desktop_file=$(find /usr/share/applications "$HOME/.local/share/applications" \
        -maxdepth 1 -iname '*zen*.desktop' -print 2>/dev/null | head -n 1) || true
    if [[ -n $desktop_file ]]; then
        desktop_id=$(basename -- "$desktop_file")
        xdg-settings set default-web-browser "$desktop_id"
        xdg-mime default "$desktop_id" x-scheme-handler/http x-scheme-handler/https text/html
    else
        die 'Fichier .desktop de Zen introuvable ; installer Zen avant services.'
    fi
    printf 'Services activés. Fermer la session puis se reconnecter sous i3.\n'
}

install_vpn() {
    target_only
    local source_file="$HOME/.config/wg/wgHome.conf"
    [[ -s $source_file ]] || die 'Configuration VPN absente ; lancer apply.'
    # Config comes from the encrypted dotfiles, not from a plaintext repository file.
    sudo install -d -m 700 /etc/wireguard
    sudo install -m 600 "$source_file" /etc/wireguard/wgHome.conf
    printf 'VPN installé, sans connexion automatique. Connexion : sudo wg-quick up wgHome\n'
}

case ${1:-help} in
    packages) install_packages ;;
    runtime) install_runtime ;;
    init) init_config ;;
    gisland) install_gisland ;;
    preview)
        need chezmoi
        # Do not print plaintext secrets in a terminal diff.
        cm apply --dry-run --verbose --exclude encrypted
        ;;
    apply) apply_config ;;
    services) enable_services ;;
    vpn) install_vpn ;;
    verify) exec python3 "$repo_dir/scripts/verify-laptop.py" ;;
    help|--help|-h)
        printf '%s\n' \
            'Étapes sur le laptop CachyOS, dans cet ordre :' \
            '  packages  Installer les paquets et Zen' \
            '  runtime   Installer NVM, la dernière LTS Node, pnpm et Codex' \
            '  init      Initialiser Chezmoi et déchiffrer la clé age (phrase secrète)' \
            '  preview   Voir les changements sans les appliquer (secrets exclus)' \
            '  apply     Sauvegarder puis appliquer les dotfiles' \
            '  gisland   Construire et installer la version Gisland conservée' \
            '  services  Activer les services, Docker et Zen par défaut' \
            '  vpn       Installer le profil WireGuard, sans le connecter' \
            '  verify    Vérifier les outils et services depuis la session i3' \
            '' \
            'Vérification isolée du dépôt : python3 scripts/validate.py' \
            'Aucune étape ne supprime automatiquement les paquets déjà installés.'
        ;;
    *) die "Étape inconnue : $1 (voir --help)" ;;
esac
