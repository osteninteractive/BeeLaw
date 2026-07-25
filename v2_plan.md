# BeeLaw v2
# Game Design Document étendu

## Architecture des changements

### 1. GameManager v2
- Statistiques détaillées (stats_tracker)
- Générations de reines (queen_generation)
- Mutations (mutations)
- Compétences de la reine (queen_skills)
- Système d'événements (events)
- Gestion des biomes (biome)
- Collection (collection)
- Arbre politique (political_tree)

### 2. Fleurs v2
Chaque fleur = {nom, biome, nectar, pollen, rarete, temps_pousse, sprite}
- Pissenlit : prairie, commun, pousse rapide, peu rentable
- Lavande : lavande, rare, lente, très rentable
- Acacia : forêt, épique, lent, énorme rendement
- Coquelicot : prairie, commun, moyen
- Tournesol : tournesols, rare, moyen
- Bleuet : champ de colza, commun
- Digitale : forêt, rare
- Romarin : méditerranée, commun
- Olivier : méditerranée, épique
- Sapin : montagne, rare
- Edelweiss : montagne, légendaire

### 3. Compétences Reine
- Cri Royal : ×2 vitesse travail 10s (cooldown 60s)
- Nouvelle Ponte : +5 ouvrières instant (cooldown 120s)
- Essaim : ×3 récolte 8s (cooldown 90s)

### 4. Spécialisations Ouvrières
- Butineuse : récolte ×2
- Gardienne : attaque ennemis
- Infirmière : ralentit pesticides (-50%)
- Éclaireuse : trouve fleurs rares
- Architecte : +20% vie ruche

### 5. Ennemis v2
- Frelon : 5 PV, attaque ouvrières
- Ours : 20 PV, mange miel
- Araignée : piège les abeilles
- Guêpes : essaim rapide
- Tondeuse : détruit les fleurs
- Pesticides avion : barre rouge massive
- Frelon géant : 50 PV, boss

### 6. Événements (toutes les 2-5min)
- Printemps humide : +50% fleurs
- Canicule : fleurs meurent plus vite
- Floraison : récolte ×3
- Ours endormi : pas d'ours 5min
- Agriculteur bio : pas de pesticides 2min

### 7. Arbre Politique
- Chaque loi = avantage ET inconvénient
- Ex: Interdire glyphosate → +15% santé mais -20% dollars

### 8. Biomes
Progression : Prairie → Lavande → Tournesols → Forêt → Montagne → Verger → Colza → Méditerranée
Déblocage : X honey total produit

### 9. Collection
- Flore : 30 fleurs
- Insectes : 25 espèces
- Oiseaux : 15 espèces  
- Mammifères : 10 espèces

### 10. Objectif final
- Voter les 13 lois → victoire
- Sauver l'espèce → écran de fin
- Prestige II (difficulté accrue)

### 11. Équilibrage v2
- Ouvrière : 250 honey (au lieu de 100)
- Croissance +25-50% par niveau
- Ennemis : fenêtre aléatoire ±30s
- Santé ruche : 8min base (au lieu de 5)
- Joueur peut prolonger via choix (infirmière, lois)
