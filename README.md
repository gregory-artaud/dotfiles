# Dotfiles — laptop CachyOS + i3

Configuration personnelle gérée par [Chezmoi](https://www.chezmoi.io/), préparée
à partir du home de l’ancien laptop et des choix validés le 10 octobre 2026.
Branche de préparation : `laptop-cachyos-i3`.

## Configuration retenue

| Domaine | Conservé |
| --- | --- |
| Bureau | i3, Picom, autotiling, feh, autorandr, Compose sur Ctrl droit |
| Interface | Gisland : horloge/calendrier, audio, notifications, batterie, lanceur, alimentation |
| Verrouillage | i3lock et xss-lock avant veille |
| Terminal | Alacritty, Zsh CachyOS, Powerlevel10k sobre, Hack Nerd Font |
| Éditeurs | Neovim et Zed avec réglages et raccourcis personnels |
| Utilitaires | Yazi, Spectacle, presse-papiers, luminosité et contrôles multimédias |
| Navigateur | Zen Browser par défaut, raccourci i3 `Mod+w` |
| Développement | NVM, dernière LTS de Node à l’installation, pnpm, Docker/Compose, DBeaver |
| Réseau | WireGuard vers le domicile |
| Codex | Préférences, barre d’état, instructions et skills de l’ancien laptop ; Context7 uniquement |
| SSH | `id_github` et `id_home_lab`, chiffrées avec age dans ce dépôt |
| GPG | Import depuis le serveur, effectué séparément |

Sur CachyOS, la commande `i3lock` est fournie par le paquet `i3lock-color`, requis
par `cachyos-i3wm-settings`. Le paquet concurrent `i3lock` n’est pas installé.

Écartés : module Tesserish et son raccourci, Polybar, Rofi, Sway, Waybar, swaync,
Hyprlock, Cursor, OpenCode et son raccourci, anciens Node, Bun, Yarn, Go, Rust,
Terraform, anciens navigateurs, NetBird, Slack, RustDesk et FileZilla.
Les dix alias « blague » du bloc `marc` à `donut-sucre-au-sucre` sont retirés.
Les alias utilitaires et `gwtr` sont conservés ; `gwtr` garde son comportement
de suppression forcée des worktrees sélectionnés.

Les plugins Codex seront réinstallés au besoin. Les historiques, sessions,
identifiants de connexion Codex, anciennes autorisations de commandes et chemins
de projets approuvés ne sont pas repris. Les skills intégrés à Codex (`.system`)
sont fournis par son installation. Les skills personnels sont conservés comme
sources ; leurs éventuels services externes seront à reconnecter au besoin.

## État de la préparation

GitHub et la copie Chezmoi archivée avaient le même commit de base, `96ef79a`.
Les configurations ont été reprises depuis les fichiers effectivement utilisés
dans le home archivé. L’archive reste intacte.

Les fonctionnalités Gisland utilisées étaient en avance sur `main`.
`vendor/gisland.patch` conserve la différence entre la révision publique
`c96f7b2` et la révision locale `8669903` (`codex/hidden-mode`, intégration du menu
d’alimentation). `vendor/gisland.env` fixe les révisions et l’arbre Git attendu.
Le script reconstitue et vérifie cet arbre avant compilation. Les binaires et
modules distribués viennent de ces sources ; les modules et thèmes personnels
restent gérés par Chezmoi. Le patch pourra être retiré quand cette version sera
publiée en amont.

Les profils autorandr de l’ancien matériel et la commande xrandr avec `HDMI-A-0`
ne sont pas repris. `Mod+Ctrl+l` verrouille la session ; le menu d’alimentation
Gisland reste sur `Mod+p`.

## Vérifier sans appliquer au serveur

```sh
python3 scripts/validate.py
```

Outils requis : Python 3.11+, Chezmoi, Bash, Zsh, i3, Lua/luac et OpenSSH.
Le contrôle rend les fichiers dans un home temporaire privé, vérifie les syntaxes
et les choix de migration, puis teste une seconde application. Il ne lance aucun
hook ni service et exclut les fichiers chiffrés sans identité age fournie.

Pour tester également le déchiffrement, sans afficher les secrets :

```sh
python3 scripts/validate.py --identity /chemin/vers/key.txt
```

Ces deux contrôles ont réussi pendant la préparation. La reconstruction Gisland
avec la base publique et le patch a produit exactement l’arbre Git attendu.
La compilation complète de Gisland et le comportement graphique n’ont pas été
testés sur ce serveur.

## Installer sur le nouveau laptop

Exécuter cette section **sur le laptop**, sous ton utilisateur, après installation
de CachyOS avec i3. Les chemins supposent les répertoires XDG par défaut.
Aucune installation n’est déclenchée par un clone ou un simple `chezmoi apply`.

Transférer d’abord la branche préparée : elle n’est pas publiée sur GitHub.
Un bundle Git autonome est fourni : `dotfiles-laptop-20261010.bundle`. Après avoir
copié ce fichier sur le laptop, il permet de cloner la branche sans publication :

```sh
git clone --branch laptop-cachyos-i3 /chemin/dotfiles-laptop-20261010.bundle "$HOME/.local/share/chezmoi"
cd "$HOME/.local/share/chezmoi"
git remote set-url origin git@github.com:gregory-artaud/dotfiles.git
```

Si `~/.local/share/chezmoi` existe déjà, choisir un autre répertoire vide pour le
clone. `init` mémorise cet emplacement. Après publication, un clone HTTPS de la
branche conviendra aussi. Garder cette copie à son emplacement tant qu’elle sert
de source Chezmoi.

Puis lancer les étapes séparément :

```sh
./scripts/setup.sh packages
./scripts/setup.sh runtime
./scripts/setup.sh init
./scripts/setup.sh preview
./scripts/setup.sh apply
./scripts/setup.sh gisland
./scripts/setup.sh services
./scripts/setup.sh vpn
```

- `packages` met à jour CachyOS et installe la liste versionnée. Zen vient des
  dépôts disponibles, sinon de `zen-browser-bin` via paru. Paru doit déjà être
  installé pour le recours à l’AUR. Les confirmations de pacman/paru restent
  actives ; aucun paquet existant n’est désinstallé.
- `runtime` installe NVM si absent (`v0.40.8`), la dernière LTS, puis pnpm et Codex
  via npm. Aucun ancien runtime ni paquet global n’est copié. Si NVM était déjà
  utilisé, les versions restantes sont affichées plutôt que supprimées.
- `init` écrit la configuration Chezmoi et demande la phrase secrète de
  `key.txt.age` si l’identité manque. Aucun dotfile n’est appliqué.
- `preview` montre les changements sans les écrire et exclut les contenus
  chiffrés pour éviter d’afficher les secrets dans le terminal.
- `apply` sauvegarde les fichiers existants concernés dans une archive privée
  sous `~/.local/state/dotfiles/backups/`, puis applique les fichiers. L’ancien
  `~/.alacritty.toml` est supprimé au profit de `~/.config/alacritty/alacritty.toml`.
  Chezmoi peut demander confirmation pour les fichiers modifiés localement.
- `gisland` compile avec deux jobs par défaut, installe sous `~/.local` et ne
  démarre pas le service. Lancer cette étape depuis un terminal de la session
  graphique : le contrôle des dépendances GTK doit pouvoir ouvrir l’affichage.
  Par SSH, transmettre les valeurs `DISPLAY` et `XAUTHORITY` de cette session.
  Ajuster `DOTFILES_BUILD_JOBS` si souhaité.
- `services` active l’agent SSH, Gisland, NetworkManager et Docker, ajoute
  l’utilisateur au groupe Docker, choisit Zsh comme shell et Zen comme navigateur.
  Gisland démarre à l’ouverture d’i3, après import des variables X11. Dunst est
  masqué pour laisser les notifications à Gisland.
- `vpn` installe le profil déchiffré avec des permissions privées dans
  `/etc/wireguard/wgHome.conf`, sans activer la connexion.

Après `init`, Chezmoi pointe vers cette copie de travail. Les commandes habituelles
`chezmoi status` et `chezmoi apply` peuvent ensuite servir. Les commits et pushes
automatiques sont désactivés.
Attendre la publication de cette branche avant d’utiliser `chezmoi update`.

Fermer la session et se reconnecter sous i3, puis :

```sh
./scripts/setup.sh verify
```

Ouvrir Neovim pour installer ses plugins avec Packer (`:PackerSync` si nécessaire).
Mason installe les serveurs TypeScript et ESLint. Les outils propres à un projet,
comme Prettier, restent à installer dans ce projet. Zed conserve le mode Vim et
les raccourcis existants, dont le profil nommé « Cursor » : cela ne nécessite pas
l’installation de Cursor. Son ancien modèle Codex fixe et ses anciennes
connexions MCP intégrées ont été retirés.

## Finaliser sur le matériel réel

1. Vérifier le fond d’écran, le lanceur, les notifications et le menu Gisland.
2. Verrouiller avec `Mod+Ctrl+l`, puis suspendre/réveiller : l’écran doit rester
   verrouillé. xss-lock assure le verrouillage avant veille ; aucun délai
   d’inactivité supplémentaire n’est imposé par ce dépôt.
3. Tester volume, micro, luminosité, lecteur multimédia et Spectacle.
4. Sauvegarder le profil écran seul avec `autorandr --save mobile`, puis chaque
   disposition utile (`autorandr --save dock`, etc.). Tester le branchement et
   débranchement. Aucun ancien identifiant d’écran n’est forcé.
5. Vérifier l’adresse `192.168.1.134` de `home_lab`, puis tester
   `ssh -T git@github.com` et `ssh home_lab`. Les clés sont ajoutées à l’agent
   à leur utilisation ; leurs phrases secrètes peuvent être demandées.
6. Tester `docker info` après reconnexion et ouvrir DBeaver. Les données des bases
   locales et profils de connexion DBeaver ne font pas partie des dotfiles.
7. Tester `sudo wg-quick up wgHome`, l’accès au domicile et les routes, puis
   `sudo wg-quick down wgHome`. Le profil vient du dépôt chiffré : vérifier son
   endpoint et son identité réseau avant usage simultané sur un autre appareil.
8. Se connecter à Codex, tester Context7 et réinstaller les plugins souhaités.
   Les anciennes connexions de compte ne sont pas transférées.

## Importer les clés GPG du serveur

Les anciennes clés GPG du laptop ne sont plus gérées. Un outil séparé prépare
le transfert chiffré des clés **actuelles du serveur** et de leurs niveaux de
confiance. Rien n’est exporté pendant `chezmoi apply`.

Sur le serveur, depuis cette copie du dépôt :

```sh
./scripts/gpg-transfer.sh export /chemin/prive/cles-serveur.tar.gpg
```

Transférer le fichier chiffré vers le laptop par SSH, puis sur le laptop :

```sh
./scripts/gpg-transfer.sh import /chemin/prive/cles-serveur.tar.gpg
gpg --list-secret-keys --keyid-format LONG
```

GPG demande les phrases secrètes nécessaires. Les fichiers temporaires sont
nettoyés ; les clés privées ne sont jamais écrites sur la sortie du terminal.
Le fichier de transfert n’a pas vocation à être ajouté au dépôt.

## Références

- [NVM : installation, versions et LTS](https://github.com/nvm-sh/nvm)
- [Chezmoi : chiffrement](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/)
- [xss-lock : verrouillage et veille](https://man.archlinux.org/man/xss-lock.1.en)
- [Hack Nerd Font : fichiers Arch](https://archlinux.org/packages/extra/any/ttf-hack-nerd/files/)
