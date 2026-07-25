# BeeLaw — Architecture du projet

## Structure des fichiers

```
BeeLaw/
├── Scripts/
│   ├── GameManager.gd          # Autoload — État global, économie, sauvegarde, politique
│   ├── BeeManager.gd           # Abeilles ouvrières, guerrières, skills reine
│   ├── FlowerManager.gd        # Fleurs (spawn, PV, récolte, repousse)
│   ├── ThreatManager.gd        # Frelons et ours (spawn, comportement)
│   ├── prestige_items.gd       # Données des articles Prestige (source unique)
│   └── UI/
│       ├── UpgradeTree.gd      # Arbre d'améliorations (menu principal)
│       └── UpgradeNode.gd      # Nœud d'amélioration individuel
├── Scenes/
│   ├── Main/Main.gd            # Coordonnateur principal (Node2D)
│   ├── Menu/Menu.gd            # Écran titre
│   ├── Menu/SettingsPanel.gd   # Paramètres (langue)
│   ├── GameOver/GameOverScreen.gd  # Écran Game Over + boutique Prestige
│   ├── Assemblee/AssembleeScreen.gd # Assemblée nationale (votes pesticides)
│   └── Main/DebugPanel.gd      # Panneau debug (F12, si DEBUG_MODE)
├── Tests.gd                    # Tests automatisés (49 tests)
└── test_before_send.py         # Validation pré-livraison
```

## Flux du jeu

```
Menu → [Play] → Main (boucle jeu)
                      │
                      ├── Clic fleur → _envoyer_abeille() → FlowerManager.recolter() → gain 🍯
                      ├── Ouvrière auto → BeeManager._demarrer_cycle() → récolte → 🍯
                      ├── Timer frelon → ThreatManager.spawn_frelon()
                      ├── Timer ours → ThreatManager.spawn_ours()
                      ├── Clic ennemi → _clic_frelon/ours → BeeManager.spawn_blue_bee()
                      ├── [⬆] → UpgradeTree (arbre d'achats)
                      ├── [📜] → AssembleeScreen (votes pesticides)
                      └── Santé ruche ≤ 0 → GameOverScreen → Restart
```

## Managers

| Manager | Rôle | Dépendances |
|---------|------|-------------|
| **GameManager** | Autoload — sauvegarde, économie, stats, politique | Aucune |
| **Main** | Coordonnateur — crée/relie les managers, UI, timers | Tous |
| **BeeManager** | Ouvrières (cycles), guerrières (blue bee), skills reine | Main (référence) |
| **FlowerManager** | Spawn, PV, récolte, barre de vie, repousse | Main (parent Node2D) |
| **ThreatManager** | Frelons et ours (spawn, comportement) | Main (référence) |

**Principe :** Les managers émettent des signaux. La UI écoute. Aucun manager ne modifie la UI directement.
Note : Actuellement certains managers passent par leur référence `_main` plutôt que par des signaux — le découplage par signaux purs est un objectif pour les prochains sprints.

## Sauvegarde

- Format : Binaire via `store_var()` / `get_var()`
- Fichier : `user://beelaw.save`
- **Stratégie :** `d.get("cle", valeur_par_defaut)` partout → compatibilité ascendante
- **Migration :** Toutes les clés manquantes sont créées automatiquement via un dictionnaire de valeurs par défaut

### Données sauvegardées (dictionnaire)
```
{
  "honey": int, "dollars": int, "honey_this_run": int,
  "ouvrieres": int, "deputes": int,
  "niveau_clic": int, "niveau_vitesse_ouvriere": int,
  "niveau_capacite_ouvriere": int, "niveau_vitesse_click": int,
  "niveau_guerriere": int, "biome_actuel": int,
  "generation": int, "langue": "fr"|"en",
  "lois_votees": {...},
  "shop_niveaux": {...}, "mutations": {...}, "ouvriere_specs": {...},
  "stats": {...}
}
```

## Événements

```gdscript
signal honey_change(valeur)
signal dollars_change(valeur)
signal evenement(nom, duree)
signal biome_change(biome_id)
```

Tous émis par `GameManager`. Les écrans UI se connectent dans `_ready()`.

## Biomes

10 fleurs réparties sur biomes 0-5 :
- Biome 0 : Pissenlit (5PV), Coquelicot (8PV), Marguerite (12PV)
- Biome 1 : + Lavande (20PV), Romarin (18PV)
- Biome 2 : + Tournesol (30PV)
- Biome 3 : + Digitale (35PV), Acacia (50PV)
- Biome 4 : + Edelweiss (80PV)
- Biome 5 : + Pommier (60PV)

**Règle :** Plus une fleur a de PV → moins elle apparaît fréquemment (poids = 100/PV).

## Économie

| Ressource | Usage |
|-----------|-------|
| 🍯 Miel | Upgrades temporaires, achat ouvrières |
| 💵 Dollars | Upgrades permanents (Prestige) |
| 👤 Députés | Votes Assemblée |

**Conversion :** 1000🍯 → 1💵 (automatique à chaque palier)

## Politique

13 pesticides à interdire via l'Assemblée. Chaque vote coûte des députés.
Quand les 13 sont interdits → 🎉 VICTOIRE !

## Tests

```bash
# Compilation
godot --headless

# Tests automatisés
godot --headless Tests.tscn

# Validation pré-livraison
python3 test_before_send.py
```
