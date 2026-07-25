# AUDIT BeeLaw — Sprint 0
## Généré le 20 juillet 2026

---

## 1. Fichiers GDScript (14)

| Fichier | Statut | Rôle |
|---------|--------|------|
| `Scripts/GameManager.gd` | ✅ Actif | État global, économie, sauvegarde, politique |
| `Scenes/Main/Main.gd` | ✅ Actif | Boucle principale, coordination |
| `Scripts/BeeManager.gd` | ✅ Actif | Abeilles ouvrières, guerrières, skills |
| `Scripts/FlowerManager.gd` | ✅ Actif | Fleurs (spawn, PV, repousse, rareté) |
| `Scripts/ThreatManager.gd` | ✅ Actif | Frelons et ours |
| `Scripts/UI/UpgradeTree.gd` | ✅ Actif | Arbre d'améliorations |
| `Scripts/UI/UpgradeNode.gd` | ✅ Actif | Nœud d'amélioration individuel |
| `Scripts/prestige_items.gd` | ✅ Actif | Données des articles prestige |
| `Scenes/Assemblee/AssembleeScreen.gd` | ✅ Actif | Assemblée, votes pesticides |
| `Scenes/GameOver/GameOverScreen.gd` | ✅ Actif | Écran Game Over, boutique prestige |
| `Scenes/Menu/Menu.gd` | ✅ Actif | Menu principal |
| `Scenes/Menu/SettingsPanel.gd` | ✅ Actif | Paramètres (langue) |
| `Scenes/Main/DebugPanel.gd` | ✅ Actif | Panneau debug (si DEBUG_MODE) |
| `Tests.gd` | ✅ Actif | Tests unitaires |
| `_validate_all.gd` | ⚠️ Obsolète | Validation standalone (chemin Deprecated) |

### 🔴 Inutilisé
| Fichier | Raison |
|---------|--------|
| `Scripts/UIManager.gd` | Créé mais jamais instancié ni référencé — code mort |

---

## 2. Fichiers de scène (5)

| Fichier | Statut |
|---------|--------|
| `Scenes/Menu/Menu.tscn` | ✅ Utilisé par GameManager comme scène de démarrage |
| `Scenes/Main/Main.tscn` | ✅ Chargé depuis Menu |
| `Scenes/GameOver/GameOverScreen.tscn` | ✅ Chargé depuis Main |
| `Scenes/Assemblee/AssembleeScreen.tscn` | ✅ Chargé depuis Main |
| `Tests.tscn` | ✅ Pour les tests automatisés |

---

## 3. Code mort détecté

### Dans `Main.gd`
| Ligne | Problème |
|-------|----------|
| `var _sante_timer` | Déclarée mais jamais lue après écriture |
| `var _fleure_areas`, `_fleurs_hp`, `_fleurs_data` | Déclarées mais FlowerManager gère maintenant |
| Ancien `_ajouter_ouvriere()` | Remplacé par `BeeManager.ajouter_ouvriere()` |
| Ancien `_demarrer_cycle_ouvriere()` | Remplacé par `BeeManager._demarrer_cycle()` |
| Ancien `_retirer_ouvriere()` | Remplacé par `BeeManager.retirer_ouvriere()` |
| Ancien `_spawn_fleurs()` inline | Remplacé par `FlowerManager.spawner()` |
| Ancien `_creer_sprite_frelon()` | Remplacé par `ThreatManager._creer_sprite_frelon()` |
| Ancien `_creer_sprite_ours()` | Remplacé par `ThreatManager._creer_sprite_ours()` |
| Ancien `_use_skill()` inline | Remplacé par `BeeManager.utiliser_skill()` |
| Ancien `_spawn_blue_bee()` inline | Remplacé par `BeeManager.spawn_blue_bee()` |
| Ancien `_acheter_upgrade()` | Remplacé par `UpgradeNode._acheter()` |
| Ancien `_ajouter_upgrade()` | Remplacé par `UpgradeNode.setup()` |
| Ancien `_sep()` | Plus utilisé (UpgradeNode gère seul) |

### Dans `UIManager.gd`
| Tout le fichier | Jamais instancié, jamais référencé |

---

## 4. Fonctions publiques jamais appelées

| Fichier | Fonction | Raison probable |
|---------|----------|-----------------|
| `GameManager.gd` | `get_fleur_data()` | Sert à la collection (non terminée) |

---

## 5. Variables inutilisées

| Fichier | Variable | Raison |
|---------|----------|--------|
| `Main.gd` | `_sante_timer` | Lue 0x après écriture |
| `Main.gd` | `_fleure_areas` (déclaration) | FlowerManager gère maintenant |
| `Main.gd` | `_fleurs_hp` (déclaration) | FlowerManager gère maintenant |
| `Main.gd` | `_fleurs_data` (déclaration) | FlowerManager gère maintenant |

---

## 6. Constantes dupliquées

| Donnée | Où | Problème |
|--------|----|----------|
| Articles prestige | `prestige_items.gd` vs ancien `GameOverScreen.gd` | ✅ Résolu — externalisé |
| Pesticides | `AssembleeScreen.gd` vs ancien `GameManager.LOIS` | ✅ Résolu — LOIS supprimé |

---

## 7. Bugs connus

| Bug | Gravité | Statut |
|-----|---------|--------|
| Pause après Restart | 🔴 Bloquant | ✅ Corrigé (P0) |
| Double création ouvrières | 🔴 Bloquant | ✅ Corrigé (P1a) |
| Stats miel_ouvrieres manquantes | 🟡 Moyen | ✅ Corrigé (P1c) |
| Migration sauvegarde | 🟡 Moyen | ✅ Corrigé |
| Fleur morte pendant trajet | 🟡 Moyen | ✅ Corrigé (P2b) |

---

## 8. Performances

| Problème | Impact |
|----------|--------|
| Création d'Area2D par fleur (×7) | Faible — 7 Area2D max |
| Boucle `while` dans BeeManager | Chaque ouvrière a sa boucle (max 15) |
| Tweens multiples | Normal pour un Godot idle game |
| Timers 1 seconde (santé, skills) | Négligeable |

---

## 9. Sauvegarde — compatibilité

| Champ | Migration | Statut |
|-------|-----------|--------|
| `stats.miel_ouvrieres` | ✅ Auto-créé si absent |
| `langue` | ✅ Auto-créé si absent |
| `shop_niveaux` | ✅ Auto-créé si absent |
| Tous les stats manquants | ✅ Auto-créés via `d.get()` |

---

## 10. Conclusion

**Prêt pour le Sprint 0 ?** ⚠️ Réserves :
- `UIManager.gd` à supprimer ou intégrer
- Variables `_sante_timer`, `_fleure_areas` etc. à nettoyer dans Main.gd
- `_validate_all.gd` à corriger ou supprimer
- Anciennes fonctions ouvrières à remplacer par BeeManager
