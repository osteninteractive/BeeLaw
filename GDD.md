# BeeLaw — Game Design Document

**Version :** 1.0 (Juillet 2026)
**Genre :** Idle Clicker / Incremental Game
**Moteur :** Godot 4.7
**Résolution :** 1280 x 720
**Public :** Mobile / PC (export Web)

---

## 1. Concept

BeeLaw est un jeu incrémental où le joueur incarne une reine abeille. En cliquant, des abeilles sont envoyées butiner sur des fleurs puis rapportent le miel à la ruche. Le miel permet d'acheter des améliorations et des ouvrières automatiques. Le joueur doit défendre sa ruche contre des frelons et des ours, tout en gérant la santé de la ruche qui décline à cause des pesticides. Un système de dollars (monnaie de prestige) permet des achats permanents entre les parties.

---

## 2. Écran Titre

- Fond : prairie (bg_prairie.png)
- Titre : "BeeLaw" en doré
- Sous-titre : "A bee must do what a bee must do"
- Abeille animée (battement d'ailes)
- Bouton **Play** → transition vers le jeu
- Bouton **?** → fenêtre Crédits (sons, licences)
- Bouton **Reset** → supprime la sauvegarde
- Musique d'ambiance (title_music.mp3)

---

## 3. Gameplay Principal

### 3.1 Clic et envoi d'abeille
- Le joueur clique sur l'écran
- Une abeille part de la **Reine** (centre, position 640, 300)
- Trajet : Reine → Fleur (0.5s) → Ruche (durée variable selon upgrade)
- Quand l'abeille arrive à la ruche : +1 honey (× puissance de clic)
- Son : bee_send.wav

### 3.2 Reine
- Sprite au centre de l'écran (bee_queen.png)
- Bulle BD à droite de la reine avec texte aléatoire
- Parle tous les 10 clics
- 25 répliques différentes (humour, motivation)
- Bulle avec queue triangulaire, fond blanc crème, bord gris

### 3.3 Fleurs
- 7 fleurs disposées en arc de cercle dans la prairie
- Chaque fleur a 50 HP (barre de vie verte)
- Quand HP = 0 : fleur fane (marron), désactivée 3s
- Quand toutes les fleurs sont fanées : repousse collective avec animation bounce

### 3.4 Ruche
- Position : (160, 580)
- Sprite : hive.png (échelle 0.5)
- Les abeilles y déposent le miel
- Barre de santé en haut au centre (600×32 px) : verte → rouge en 5 minutes

### 3.5 Compteurs
- **Honey** : en bas à gauche, fond noir, police 32, blanc
- **Dollars** : juste en dessous du honey, même style, police 24, vert
- **Barre de progression $** : à droite des dollars, 0→1000, jaune

---

## 4. Économie

### 4.1 Honey
- Gagné par clic (envoi d'abeille) : 1 × puissance
- Gagné par les ouvrières automatiques
- Gagné en tuant les ennemis
- Dépensé dans les upgrades (clic, vitesse, ouvrières)

### 4.2 Dollars ($)
- Monnaie de prestige (permanente entre les parties)
- 1 $ = 1000 honey produits (cumulé pendant une run)
- Gagnés progressivement (crédités instantanément dès 1000 honey atteint)
- Dépensés dans la boutique Game Over (achats permanents)

---

## 5. Ennemis

### 5.1 Frelon
- Apparition : toutes les 60 secondes
- Sprite : 3 frames animées (AnimatedSprite2D)
- Taille : scale 0.3
- PV : 5
- Trajectoire : arrive par la droite → cible une ouvrière → l'attrape → repart à gauche
- Si l'ouvrière sort de l'écran → perte définitive
- Son : hornet_buzz.wav
- **Cliquable** : abeille bleue part de la reine → -1 PV
- Récompense : 10 honey (base) +5/niveau dans la boutique

### 5.2 Ours
- Apparition : toutes les 90 secondes
- Sprite : 2 animations (marche 3 frames + mange 3 frames)
- Taille : scale 0.35
- PV : 20
- Trajectoire : arrive par la droite → marche vers la ruche (6s) → s'arrête à côté (250, 560) → mange 1 honey/sec
- Son : bear_roar.mp3
- **Cliquable** : abeille bleue part de la reine → -1 PV
- Récompense : 50 honey (base) +25/niveau dans la boutique

---

## 6. Ouvrières Automatiques (Abeilles Rouges)

- Achat : 100 honey l'unité
- Max de base : 5
- Max achetable dans la boutique : +10 slots (prix ×2 par niveau : 1, 2, 4, 8, 16...)
- Sprite : bee_worker.png, teinte rouge, échelle 0.12
- Cycle : Ruche → Fleur (3s) → Ruche (3s) → dépôt
- Capacité de base : 1 honey par voyage
- Capacité upgradable : ×2 par niveau (1, 2, 4, 8, 16, 32)

---

## 7. Améliorations (Upgrades)

Chaque upgrade a 5 niveaux, coût ×5 cumulatif.

| Upgrade | Coût base | Effet par niveau |
|---------|-----------|------------------|
| Click power | 10 honey | ×2 puissance de clic |
| Click speed | 10 honey | -0.3s vol ruche (1.5s → 0.3s) |
| Worker bee | 100 honey | +1 ouvrière rouge (max 5 + slots boutique) |
| Worker speed | 100 honey | Vol + rapide (0.5 → 0.1 multiplicateur) |
| Worker capacity | 100 honey | Capacité ×2 (1 → 2 → 4 → 8 → 16 → 32) |
| Député | 1 $ | +1 député pour voter les lois |

Couleurs des boutons :
- **Jaune** : achetable
- **Vert** : niveau max atteint
- **Rouge** : pas assez de honey/$

---

## 8. Assemblée Nationale

- Bouton "📜 Assemblée" sur l'écran de jeu
- Liste de 13 pesticides dangereux pour les abeilles
- Chaque pesticide nécessite 3 à 10 députés pour voter la loi d'interdiction
- Députés achetés en dollars (1 $/unité)
- Indicateur de danger : 1 à 5 pastilles rouges

Liste des pesticides :
| Pesticide | Danger | Députés requis |
|-----------|--------|---------------|
| Paraquat | 5/5 | 10 |
| Fipronil | 5/5 | 9 |
| Imidaclopride | 5/5 | 8 |
| Clothianidine | 5/5 | 8 |
| Thiaméthoxame | 5/5 | 7 |
| Acétamipride | 4/5 | 6 |
| Chlorpyriphos | 4/5 | 6 |
| Sulfoxaflor | 4/5 | 6 |
| Glyphosate | 3/5 | 5 |
| Cyperméthrine | 3/5 | 4 |
| Deltaméthrine | 3/5 | 4 |
| Lambda-cyhalothrine | 3/5 | 4 |
| Mancozèbe | 2/5 | 3 |

---

## 9. Santé de la Ruche

- Barre en haut au centre (600×32 px)
- 100% → descend à 0% en 5 minutes (1 tick/sec)
- Devient rouge quand < 30%
- Animation de pesticide à gauche de la barre (3 frames)
- Quand 0% → **Game Over**

---

## 10. Game Over / Boutique

### 10.1 Déclenchement
- Santé de la ruche = 0%
- Bouton "Restart" en haut à droite

### 10.2 Écran Game Over
- Fond : bg_gameover.png avec overlay sombre
- Titre : "GAME OVER" en rouge
- Stats : honey produit, dollars gagnés
- **Boutique d'achats permanents** (dépense des dollars)

### 10.3 Articles de la boutique
| Article | Coût | Max | Effet |
|---------|------|-----|-------|
| Boost Clic | 2 $ | 10 | +1/clic permanent |
| Ouvrière départ | 3 $ | 10 | +1 ouvrière au début |
| Miel départ | 1 $ | 20 | +50 honey au début |
| Ruche + | 5 $ | 5 | +10% santé ruche |
| Slot ouvrière | 1 $ (×2/niv) | 10 | +1 ouvrière max |
| Prime frelon | 2 $ | 10 | +5/frelon tué |
| Prime ours | 3 $ | 10 | +25/ours tué |

### 10.4 Confirmation
- Bouton "🔄 Recommencer" → popup "Oui / Non"
- "Oui" → sauvegarde des achats → restart complet
- Dollars conservés entre les parties

---

## 11. Pause

- Bouton "⏸" en haut à gauche
- Overlay sombre avec "PAUSED"
- Bouton "▶ Reprendre"
- Tout le jeu est en pause (PROCESS_MODE_ALWAYS sur l'overlay)

---

## 12. Sauvegarde

- Fichier : `user://beelaw.save`
- Sauvegardé : honey, dollars, niveaux upgrades, ouvrières, shop_niveaux
- Sauvegarde automatique après chaque dépôt de miel
- Restauration au chargement

---

## 13. UI / HUD

| Élément | Position |
|---------|----------|
| 🏠 Barre santé ruche | Haut centre (340, 5) |
| 🧪 Animation pesticide | Gauche barre (310, 25) |
| 🍯 Compteur honey | Bas gauche (20, 620) |
| 💵 Compteur dollars | Sous honey (20, 660) |
| 📊 Barre progression $ | À droite dollars (220, 666) |
| 🔄 Restart | Haut droite (1100, 10) |
| ⏸ Pause | Haut gauche (10, 10) |
| Upgrades | Droite (1100, 650) |
| 📜 Assemblée | Droite (1100, 600) |
| 👑 Reine | Centre (640, 300) |
| 🏠 Ruche | (160, 580) |

---

## 14. Crédits

**Sons :**
- Frelon : "bee bee gun shot at piano.wav" by dcolvin (CC BY 3.0)
- Abeille : "Gun Shot 1 8 Bit.wav" by Mrthenoronha (CC BY-NC 4.0)
- Ours : bear_roar.mp3
- Tir : shoot.wav
- Musique titre : title_music.mp3

**Développement :**
- Game Design : Morgan
- Code : Hermes Agent (Nous Research)
- Moteur : Godot 4.7
- Sprites : Générés via ChatGPT

---

*Document généré le 19 Juillet 2026*
