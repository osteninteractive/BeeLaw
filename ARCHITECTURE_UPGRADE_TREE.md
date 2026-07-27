# Architecture — Arbre d'Upgrades (BeeLaw v1.0)

## Composants

```
UpgradeTree (Control)
├── UpgradeCameraController (Node)
│   └── Camera2D (pan, zoom, recenter)
├── UpgradeGraph (Node)
│   ├── UpgradeBranch (x3)
│   │   ├── UpgradeNode (root + children)
│   │   └── UpgradeConnection (lines)
│   └── Data/upgrades.json
└── Overlay (close, recenter buttons)
```

## Responsabilités

| Classe | Rôle |
|--------|------|
| **UpgradeTree** | Orchestrateur : crée la scène, connecte composants, route input |
| **UpgradeCameraController** | Navigation : pan, zoom, recenter (via Camera2D) |
| **UpgradeGraph** | Données : lit `upgrades.json`, instancie les branches |
| **UpgradeBranch** | Disposition : root + enfants + connexions |
| **UpgradeNode** | Affichage : état visuel, tooltip, signal click |
| **UpgradeConnection** | Visuel : lignes entre parent et enfants |
| **GameManager** | Métier : validation, achat, sauvegarde, niveaux |

## Flux d'achat

```
Clic sur UpgradeNode
  → UpgradeNode.clicked.emit(id)
    → UpgradeGraph → UpgradeTree._on_node_click(id)
      → GameManager.buy_upgrade(id)
        → Validation (can_buy)
        → Transaction (honey - cost, niveau +1)
        → save()
        → Emit signals
      → UpgradeTree: refresh + feedback + son
```

## Données

`Data/upgrades.json` définit la structure de l'arbre :

```json
{
  "branches": [
    {"id": "forager", "root": "buy_forager", "children": ["forager_speed", "forager_capacity"]},
    {"id": "worker",   "root": "buy_worker",   "children": ["worker_speed",   "worker_capacity"]},
    {"id": "warrior",  "root": "buy_warrior",  "children": ["warrior_speed",  "warrior_damage"]}
  ]
}
```

Ajouter une branche = 1 entrée dans ce fichier + données dans GameManager.UPGRADE_IDS.

## Extensibilité

- Nouvelles branches : ajouter dans `upgrades.json` + `GameManager.UPGRADE_IDS`
- Nouveaux états visuels : modifier `UpgradeNode.refresh()`
- Nouveau comportement métier : modifier `GameManager.buy_upgrade()`
- Nouveau layout : modifier `UpgradeBranch.create()`
