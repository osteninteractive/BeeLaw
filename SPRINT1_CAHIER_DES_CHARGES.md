# BeeLaw v1.0 — Sprint 1 : Cahier des charges (suite)

## État actuel

L'arbre d'upgrades possède une architecture solide :
- 3 branches (Butineuse, Ouvrière, Guerrière) avec 9 nœuds
- Navigation Camera2D : pan, zoom, recentrage
- Architecture modulaire : UpgradeTree → UpgradeGraph → UpgradeBranch → UpgradeNode
- Données dans `Data/upgrades.json`
- API métier centralisée dans `GameManager`
- Achats instantanés avec feedback visuel + son

## Améliorations restantes du Sprint 1

### 1. Finaliser les upgrades manquantes

Plusieurs nœuds ont un effet TODO :

| ID | Branche | État | Travail |
|----|---------|------|---------|
| `forager_capacity` | Butineuse | Stub | Augmente la quantité de miel par clic |
| `warrior_speed` | Guerrière | Stub | Réduit le temps de déplacement des guerrières |
| `warrior_damage` | Guerrière | Stub | Augmente les dégâts par attaque |

**Spécifications :**

`forager_capacity` :
- Niveau 0 : 1 miel/clic
- Niveau 1 à 5 : +1 miel/niveau
- Appliqué dans `GameManager.get_puissance_clic()`

`warrior_speed` :
- Niveau 0 : vitesse de base (1.0)
- Niveau 1 à 5 : +20% vitesse/niveau
- Appliqué dans `_spawn_blue_bee()` (durée du tween)

`warrior_damage` :
- Niveau 0 : 1 dégât/clic
- Niveau 1 à 5 : +1 dégât/niveau
- Appliqué dans `_clic_frelon()` et `_clic_ours()`

### 2. Icônes PNG pour les nœuds

Remplacer les emojis (🐝, 🐜, ⚔) par de vraies icônes PNG pour chaque nœud.

Fichiers à créer dans `Assets/Sprites/Icons/` :
- `icon_forager.png`
- `icon_forager_speed.png`
- `icon_forager_capacity.png`
- `icon_worker.png`
- `icon_worker_speed.png`
- `icon_worker_capacity.png`
- `icon_warrior.png`
- `icon_warrior_speed.png`
- `icon_warrior_damage.png`

Format : 96×96, fond transparent, style cohérent.

### 3. Couleurs par branche

Chaque branche doit avoir une couleur distinctive dans les connexions et bordures :

| Branche | Couleur |
|---------|---------|
| Butineuse | Jaune/Or `#DAA520` |
| Ouvrière | Orange/Ambre `#FF8C00` |
| Guerrière | Rouge `#DC143C` |

### 4. Infobulle enrichie au survol

Actuellement le tooltip est basique. Améliorations :
- Afficher l'effet actuel (ex : « Vitesse : 0.5s → 0.4s »)
- Afficher l'effet du prochain niveau
- Indiquer le prérequis si verrouillé
- Fond semi-transparent avec bordure couleur de la branche

### 5. Animation d'achat

- Surbrillance du nœud acheté (flash jaune 200ms)
- Particules ou effet de montée de niveau
- Son distinct par type d'achat (butineuse, ouvrière, guerrière)

### 6. Panneau latéral de détails

Au clic sur un nœud (pas à l'achat), afficher dans un panneau latéral :
- Icône en grand
- Nom complet
- Description détaillée
- Niveau actuel / maximum
- Coût du prochain niveau
- Effet actuel → effet suivant
- Bouton Acheter (si disponible)

Ce panneau remplace la navigation hasardeuse entre les nœuds.

---

## Sprint 2 : Nouvelles branches (prévisionnel)

Une fois le Sprint 1 terminé, les branches suivantes seront ajoutées :

- **Reine** : Ponte accélérée, Cri Royal amélioré, Essaim étendu
- **Ruche** : Santé maximale, Régénération, Stockage miel
- **Défense** : Tourelles, Pièges, Résistance aux pesticides
- **Économie** : Prix des fleurs, Bonus pollen, Multiplicateur prestige

---

## Règles

- Aucune régression sur le système existant
- Compilation 0 erreur avant chaque livraison
- Chaque upgrade doit avoir un effet réel et vérifiable en jeu
- Architecture data-driven maintenue
