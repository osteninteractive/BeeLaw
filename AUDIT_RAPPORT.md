# Audit QA — BeeLaw (Godot 4.7)
**Date** : 19 juillet 2026
**Périmètre** : 6 fichiers GDScript, 5 scènes, 1 autoload

---

## Résumé

| Gravité | Nombre |
|---------|--------|
| 🔴 CRITIQUE | 2 |
| 🟠 HAUTE | 4 |
| 🟡 MOYENNE | 7 |
| 🔵 FAIBLE | 6 |
| **Total** | **19 anomalies** |

---

# 🔴 CRITIQUE

## C1. `GameManager.restart_apres_shop()` — Fonction inexistante (CRASH)

**Fichier** : `Scenes/Shop/ShopScreen.gd` — lignes 104 et 109
**Code** :
```gdscript
func _on_valider():
    GameManager.restart_apres_shop()   # ← N'EXISTE PAS
    ferme.emit()
    queue_free()
```
**Impact** : Appeler `_on_valider()` ou `_on_passer()` dans ShopScreen provoque un crash `Invalid function 'restart_apres_shop' in base 'Node'`. Le jeu plante immédiatement.

**Note** : ShopScreen.tscn n'est chargé par **aucun** fichier du projet (0 référence). C'est une scène orpheline. Mais si elle était instanciée, ce serait un crash immédiat.

---

## C2. Assemblée nationale — Boutons « Voter » sans signal connecté

**Fichier** : `Scenes/Assemblee/AssembleeScreen.gd` — lignes 112–122
**Code** (extrait) :
```gdscript
var btn = Button.new()
btn.text = "Voter" if peut else "👤 " + str(p.deputes)
btn.disabled = not peut
# ⚠ AUCUN .pressed.connect() sur ce bouton
dep_v.add_child(btn)
```
**Impact** : Les 13 boutons de vote sont affichés, mais aucun ne réagit au clic. La fonction `_voter_pesticide()` (ligne 133) existe mais n'est jamais connectée. **Toute la mécanique de vote des pesticides est inopérante.**

---

# 🟠 HAUTE

## H1. Achat de guerrière — Aucun `case` dans `_acheter_upgrade`

**Fichier** : `Scenes/Main/Main.gd` — lignes 702–713
**Code** :
```gdscript
func _acheter_upgrade(up_id):
    match up_id:
        "clic": ...
        "vitesse_click": ...
        "max": ...
        "vitesse_ouvriere": ...
        "capacite_ouvriere": ...
        # ⚠ PAS de case "guerriere"
```
**Impact** : Le bouton « Guerrière » est bien créé (ligne 652) avec `_ajouter_upgrade(uc, "guerriere", ...)`, mais cliquer dessus ne déclenche **rien**. `acheter_guerriere()` (dans GameManager) n'est jamais appelée via l'interface.

**Note** : `acheter_guerriere()` peut être appelé depuis la boutique prestige (`acheter_shop("guerriere_slots")`), mais elle modifie le même `shop_niveaux["guerriere_slots"]` — il y a donc **deux chemins concurrents** qui écrivent la même clé.

---

## H2. Achat d'ouvrière — Bloqué après le premier achat (UI)

**Fichier** : `Scenes/Main/Main.gd` — ligne 654
**Code** :
```gdscript
_ajouter_upgrade(uc, "max", 1, ...)  # nm = 1 (MAX)
```
`nm` (max) est codé en dur à **1**, alors que le niveau réel (`GameManager.ouvrieres`) peut monter jusqu'à 15 (`MAX_OUVRIERES_TOTAL`). Après le premier achat, `niveau >= nm → fini = true` → le bouton passe en « MAX » et se désactive.

**Impact** : Le joueur ne peut acheter qu'**une seule** ouvrière via le panneau Upgrades. La fonction `acheter_ouvriere()` elle-même permet d'en acheter plusieurs (limite = 5 + shop), mais l'UI bloque après 1.

---

## H3. `boost_capacite` — Bonus inaccessible

**Fichier** : `Scripts/GameManager.gd` — lignes 297, 324
**Code** :
```gdscript
# Dans get_capacite_ouvriere():
var base = 1 + shop_niveaux.get("boost_capacite", 0)

# Dans acheter_shop() — reconnu :
"boost_capacite": prix = 2; max_niv = 10
```
Mais `boost_capacite` n'apparaît dans **aucune** liste ARTICLES (ni GameOverScreen, ni ShopScreen). Le joueur ne peut jamais l'acheter.

**Impact** : Bonus permanent (achetable avec des dollars) qui existe dans le code mais est invisible dans toutes les interfaces. Le calcul `get_capacite_ouvriere()` le lit et retourne toujours +0.

---

## H4. Panneau Upgrades — Niveau guérrière affiché supérieur au max

**Fichier** : `Scenes/Main/Main.gd` — ligne 652
**Code** :
```gdscript
_ajouter_upgrade(uc, "guerriere", 1, "Guerrière",
    "1 max (" + str(GameManager.get_guerriere_max()) + ")",
    GameManager.COUT_GUERRIERE,
    GameManager.get_guerriere_max())  # ← "niveau" = 1 + shop, max = 1
```
**Impact** : L'affichage donne `Guerrière (3/1)` si le joueur a acheté 2 slots en boutique. Le niveau dépasse le maximum. Le bouton reste désactivé car `niveau >= nm`.

---

# 🟡 MOYENNE

## M1. Liste des 13 pesticides dupliquée 3 fois

**Fichiers** :
- `Scripts/GameManager.gd` lignes 159 et 216 : `get_sante_ruche_max()` et `get_pesticide_mult()` contiennent **chacune** la liste complète des 13 IDs
- `Scenes/Assemblee/AssembleeScreen.gd` lignes 5–19 : `PESTICIDES` contient les 13 mêmes IDs

**Risque** : Si un pesticide est ajouté/retiré/renommé dans AssembleeScreen, les deux listes dans GameManager divergent. Le calcul de `get_pesticide_mult()` et `get_sante_ruche_max()` ne correspondra plus aux lois votables.

**Recommandation** : Définir une `const PESTICIDE_IDS` unique dans GameManager et la référencer partout.

---

## M2. Événement `ours_dodo` — Aucun effet gameplay

**Fichier** : `Scripts/GameManager.gd` ligne 144 → `_spawn_ours()` dans Main.gd ligne 573
**Problème** : L'événement « Ours endormi → Pas d'ours » est défini et son nom s'affiche, mais `_spawn_ours()` ne vérifie **jamais** `GameManager.evenement_actif`. Les ours continuent d'apparaître pendant cet événement.

---

## M3. Événement `canicule` — Aucun effet gameplay

**Fichier** : `Scripts/GameManager.gd` ligne 142
**Problème** : « Canicule → Fleurs meurent x2 » s'affiche mais n'affecte aucune fonction. Aucun code ne vérifie `evenement_actif.id == "canicule"`. Les fleurs ne meurent pas plus vite.

---

## M4. Événement `pluie` — Aucun effet gameplay

**Fichier** : `Scripts/GameManager.gd` ligne 141
**Problème** : « Printemps humide → +50% fleurs » s'affiche mais n'a aucun effet. Aucun multiplicateur ne vérifie cet événement. Seuls `floraison` et `bio` sont lus par le code.

---

## M5. ShopScreen — Scène orpheline + code cassé

**Fichier** : `Scenes/Shop/ShopScreen.tscn` + `ShopScreen.gd`

**Problèmes** :
1. ShopScreen.tscn n'est instancié par **aucune** scène du projet (0 référence `load` ou `preload`)
2. Appelle `GameManager.restart_apres_shop()` qui n'existe pas (C1)
3. `_acheter()` (ligne 95–101) : `remove_child(self)` + `add_child(self)` + `queue_free()` → après un achat, le nœud est libéré et l'écran disparaît

---

## M6. `reines_repliques` — Variable dupliquée dans Main.gd

**Fichier** : `Scenes/Main/Main.gd`
- Lignes 196–210 : Déclaration `var reines_repliques = [...]` — **variable locale jamais lue**
- Lignes 411–425 : Tableau `repliques` identique dans `_parler_reine()` — celui-ci est utilisé

**Impact** : Code mort qui encombre `_construire()`. La variable définie ligne 196 n'est jamais référencée.

---

## M7. `_spawn_frelon` — Variable inutilisée

**Fichier** : `Scenes/Main/Main.gd` ligne 504
**Code** :
```gdscript
var t = 60.0 + randf() * 30.0  # Fenetre aleatoire
```
**Problème** : `t` est calculée mais jamais utilisée. Le timer frelon est fixe à 60s (ligne 26). Ce code n'a aucun effet.

---

# 🔵 FAIBLE

## F1. `niveau_reine` — Sauvegardé mais jamais utilisé

**Fichier** : `Scripts/GameManager.gd`
- Déclaré ligne 41, sauvegardé ligne 350, chargé ligne 371
- N'est **jamais** lu par une fonction de gameplay. Aucun calcul, aucune condition n'y fait référence.

---

## F2. `collection_progression` — Jamais utilisé

**Fichier** : `Scripts/GameManager.gd` ligne 126
Déclaré comme `var collection_progression: Dictionary = {}` mais n'est ni lu, ni écrit, ni sauvegardé.

---

## F3. `COLLECTION_CATS` — Jamais utilisé

**Fichier** : `Scripts/GameManager.gd` lignes 128–133
Constante définie avec 4 catégories de collection. N'apparaît dans aucune fonction. Code mort.

---

## F4. `sante_ruche_max` — Variable inutilisée

**Fichier** : `Scripts/GameManager.gd` ligne 152
```gdscript
var sante_ruche_max: float = 100.0
```
Déclarée mais **jamais lue directement**. Toutes les lectures passent par `get_sante_ruche_max()`. La variable est inerte.

---

## F5. Affichage HP frelon — Max incorrect pour frelons transversaux

**Fichier** : `Scenes/Main/Main.gd` ligne 561
**Code** :
```gdscript
_show_popup("-1 HP (" + str(hp) + "/" + str(5 if hp <= 4 else 3) + ")")
```
- Frelon ciblant : HP=5, après clic HP=4 → affiche `4/5` ✅
- Frelon transversal : HP=3, après clic HP=2 → affiche `2/5` ❌ (devrait être `2/3`)

---

## F6. `_changer_biome` — Tous les biomes utilisent le même fond

**Fichier** : `Scenes/Main/Main.gd` lignes 331–334
```gdscript
var paths = ["res://Assets/Sprites/UI/bg_prairie.png",    # biome 0
             "res://Assets/Sprites/UI/bg_prairie.png",    # biome 1
             ...  # tous identiques !
             "res://Assets/Sprites/UI/bg_prairie.png"]    # biome 7
```
Les 8 biomes pointent tous vers `bg_prairie.png`. Le changement de biome (GameManager.BIOMES avec 8 entrées uniques) n'a aucun effet visuel sur le fond.

---

# ✅ Vérifications passées

| Contrainte | Statut |
|-----------|--------|
| Signaux .pressed.connect() pour chaque bouton (sauf C2) | ✅ 22/24 connectés |
| Achat retire la ressource (honey -= cout) | ✅ Tous les achats |
| Bonus shop_niveaux lu par calcul réel | ✅ sauf boost_capacite (H3) |
| restart() reset temporaires | ✅ |
| restart() garde permanents | ✅ (shop_niveaux, mutations, stats) |
| restart() incrémente génération UNE fois | ✅ |
| Écrans pause avec process_mode adapté | ✅ (pause overlay, Assemblée) |
| Ouvrières restaurées visuellement au load | ✅ (boucle with compter=false) |
| IDs pesticides (13) correspondent entre fichiers | ✅ (identiques exacts) |
| timer_evenement pas reset par _prochain_evenement | ✅ (sépare timer_evenement et prochain_evenement) |
| d.get() avec valeurs par défaut pour vieilles saves | ✅ (tous les champs) |
| Autoload GameManager configuré | ✅ (project.godot ligne 21) |
| Scene principale configurée | ✅ (Menu.tscn) |

---

## Statistiques

- **6 fichiers GDScript** audités (3 253 lignes total)
- **1 autoload** (GameManager)
- **22 appels `.pressed.connect()`** vérifiés dans les 5 écrans
- **2 signaux manquants** (Assemblée : vote pesticides)
- **1 fonction manquante** (`restart_apres_shop`)
- **3 événements sur 5** sans effet gameplay
- **5 variables/constantes** mortes
- **3 listes de pesticides** dupliquées
