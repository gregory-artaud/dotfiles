# Ressources de Grégory

Inventaire observé le 14 septembre 2026. La présence d'un dépôt, d'un binaire ou d'un outil ne garantit ni son actualité ni la disponibilité de son service distant. Redécouvrir les capacités utiles à chaque enquête ; cette liste n'est pas une obligation de tout consulter.

## PXP / Project X Paris

| Ressource | Usage et points d'entrée |
| --- | --- |
| `/home/gartaud/Projects/pxpr-monorepo` | Dépôt Git bare avec plusieurs worktrees, dont `dev` et `main`. Exécuter `git -C /home/gartaud/Projects/pxpr-monorepo worktree list` avant de choisir. GitHub : `galadrimteam/pxpr-monorepo`. |
| `<worktree>/apps/caisse-{backend,frontend}` et `apps/caisse-electron` | Caisse/POS boutique, API, UI et client Electron. |
| `<worktree>/apps/operations-{backend,frontend}` | Backoffice : modules backend sous `src/modules`, fonctionnalités frontend sous `src/features`. |
| `<worktree>/apps/logistics-{backend,frontend}` | Réécriture Logistics ; vérifier quelle application sert réellement le flux étudié. |
| `<worktree>/packages/{contracts,core,database}` | Schémas/constantes/règles partagées, droits et périmètres, accès MySQL/Kysely et schémas générés sous `database/src/generated`. |
| `<worktree>/packages/{integration,observability,runtime-config}` | Intégrations S3/Mailgun, code de logs/alertes, configuration runtime. Leur présence ne signifie pas accès direct à S3, Mailgun, Slack ou aux logs de production. |
| `<worktree>/docs/{ARCHITECTURE,DEPLOYMENT,CI,FEATURE_FLAGS,MIGRATION}.md`, `infra/`, `.github/`, `tests/` | Architecture, déploiement, activation des fonctionnalités, migrations, infrastructure et validations existantes. Lire les scripts avant toute exécution : certains ciblent la production ou plusieurs bases. |
| `/home/gartaud/Projects/pxpr-operations` | Dépôt Operations historique distinct ; `server/`, `react/`, `views/`, `db/`, `server/crons/`. GitHub : `galadrimteam/pxpr-operations`. Également référencé par `archive/operations-old` dans le monorepo. |
| `<worktree>/archive/pxp-logistics` | Application Logistics **active**, Laravel/PHP, dépôt `galadrimteam/pxp-logistics`. Ne pas la classer comme abandonnée à cause du dossier `archive`. Sous-module à disponibilité locale variable. |
| `/home/gartaud/Projects/pxpr-caisse`, `pxpr-caisse-refonte`, `pxpr-extension-host` | Autres dépôts PXP présents. Vérifier README, remotes et historique pour établir leur rôle actuel. Sous-modules également déclarés : `archive/caisse-old`, `archive/pxpr-extension-host`, `archive/pxpr-extension`. |

La documentation observée distingue le déploiement Operations via `main` de celui de Caisse via release/tag. Revalider dans les workflows actuels avant toute conclusion sur la production.

## Outils disponibles lors de l'inventaire

| Capacité | Accès observé | Utilisation |
| --- | --- | --- |
| MySQL PXP | `mcp__mysql_pxp__mysql_query`, multi-base, lecture seule | Vérifier schémas, données et périmètres pertinents. Connexion/données non interrogées pour cet inventaire. |
| PostgreSQL MGE | `mcp__postgres_mge_prod__query`, lecture seule | Pour Mission Grande École uniquement si le sujet le justifie ; nom du serveur indiquant prod, à confirmer dans le contexte. Connexion non testée. |
| PostgreSQL Sofradef | `mcp__postgres_sofradef__query`, lecture seule | Pour Sofradef ; environnement à identifier. Connexion non testée. |
| YouTrack | `mcp__youtrack__search_issues`, `get_issue`, `get_issue_comments`, `search_articles`, `get_article`, outils projets | Tickets et base de connaissances. Outils d'écriture également exposés, hors diagnostic implicite. Service non testé lors de l'inventaire. |
| GitHub | CLI `gh` installée et authentifiée comme `gregory-galadrim` | Lire PR, diffs, issues, releases et exécutions CI ; préciser le dépôt avec `--repo`. Droits effectifs par dépôt à vérifier. Pas de MCP GitHub exposé lors de l'inventaire. |
| Documentation technique | MCP Context7 : `resolve_library_id`, `query_docs` ; outil web | Documentation des bibliothèques et sources officielles actuelles. Ne pas envoyer de contenu confidentiel du mail dans une recherche publique. |
| Navigation | `mcp__cua_repl` | Navigateur et pages accessibles, avec les APIs documentées par l'outil. Applications natives désactivées dans la session observée. |
| Tâches Codex | `list_projects`, `list_threads`, `read_thread`, `wait_threads` | Retrouver une enquête ou une décision pertinente. La liste des projets enregistrés ne couvre pas tous les dépôts locaux. |
| Shell et analyse locale | `exec_command`, `rg`, Git, Node, pnpm, Python ; binaires Docker, mysql, psql présents ; MCP Node REPL | Recherche dans le code, historique et analyse ciblée. Binaire installé ne signifie pas service actif ou base accessible. |
| Documents et visuels | Skills PDF, documents, spreadsheets, presentations, visualize ; imagegen ; outils de rendu et dépendances via `load_workspace_dependencies` | Examiner les pièces effectivement fournies/accessibles et produire un visuel seulement s'il clarifie le problème. |

Gmail, Trello, Slack et Google Drive ne présentaient pas de connecteur callable dans cet inventaire. Des skills Google Drive sont installés et `pxp-activity-summary` décrit un workflow Gmail/GitHub/Trello : cela ne prouve pas la disponibilité des connexions. Rechercher les outils disponibles dans la session avant usage, puis exploiter le mail collé si l'accès manque. Les plugins seulement recommandés par l'application ne sont pas installés. Ne pas installer ni connecter un service pour le simple diagnostic.

## Autres dépôts et répertoires locaux

Sous `/home/gartaud/Projects`, dépôts Git constatés au premier niveau (hors PXP déjà listés) : `ac-expo-mobile`, `ceraplus-refonte`, `click-and-glow`, `daniel-moquet`, `docker-tswow`, `formation-chat-back`, `formation-chat-front`, `galacrypt`, `galactf`, `gatus`, `gisland`, `gisland-platform-host`, `gisland-rlgl-renderer`, `git-formation`, `gort`, `gra-ui`, `greact-hooks`, `hiring-test-hangman`, `ia-morpion`, `le-fond`, `linux`, `massilia-voyages`, `mission-grande-ecole`, `soli-app`, `terraform`, `tesserish`, `test-maid`, `trouve-ton-formateur`, `uniqmaker`, `upnail`, `ws-http-benchmark`.

Dépôts imbriqués constatés : `sofradef/sofradef-front`, `sofradef/sofradef-server`, `maid/jwt-cli`, `maid/web`. Worktrees constatés également dans `trouve-ton-formateur/{main,dev,staging}` et `uniqmaker/{dev,main}`.

Autres répertoires présents, rôle et contenu non audités : `bdd`, `el-mordjene`, `entretien`, `greact-test`, `local-mysql`, `local-postgres`, `pascal-db`, `platformer`, `slack`, `slack-spoof`, `sql-scripts`. Leur nom ne prouve aucun accès distant.

Projets Codex enregistrés : Sofradef, soli-app, gisland, mission-grande-ecole ; un projet ChatGPT « Raphaël » est également listé. L'hôte `home_lab` est proposé par les outils de transfert, mais son contenu et ses accès n'ont pas été vérifiés. Ne pas transférer une tâche pour découvrir des ressources.
