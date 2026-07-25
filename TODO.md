# BeeLaw — Todo List Projet
# Généré le 19 juillet 2026

## LÉGENDE
# [ ] À faire
# [~] En cours
# [x] Terminé
# [ ] ? Bloqué / À discuter

---

## PRIORITÉ 1 — BOUCLE PRINCIPALE (jouable et stable)

[x] P1-1: Économie clic — puissance, coût, achat déduit honey
[x] P1-2: Butineuse (abeille clic) — lien vers fleur, gain
[x] P1-3: Ouvrières — achat, compteur, max, sauvegarde
[x] P1-4: Guerrière — max 1, achat slot prestige
[x] P1-5: Frelon — spawn, cliquable, récompense
[x] P1-6: Ours — spawn, cliquable, récompense, mort
[x] P1-7: Barre santé ruche — tick, game over
[x] P1-8: Pause — overlay, process_mode WHEN_PAUSED
[x] P1-9: Restart — confirmation, reset tempo, garde perm, gen+1
[x] P1-10: Sauvegarde — save/load complet
[ ] P1-11: Fleurs — épuisement, repousse, rareté fonctionnelle
[ ] P1-12: Événements — ours_dodo arrête ours, canicule ×2 dégâts, pluie ×1.5 récolte

## PRIORITÉ 2 — SYSTÈME POLITIQUE

[x] P2-1: Assemblée — 13 pesticides avec IDs uniques
[x] P2-2: Vote — boutons connectés, débit députés
[x] P2-3: Effets pesticides — get_pesticide_mult() basé sur IDs
[x] P2-4: Effets santé — get_sante_ruche_max() basé sur IDs
[ ] P2-5: Compteur lois — afficher X/13
[ ] P2-6: Ancien système 5 lois — supprimer les constantes LOIS inutilisées
[ ] P2-7: Objectif final — voter les 13 lois = victoire (proposition)

## PRIORITÉ 3 — BOUTIQUE PRESTIGE (Game Over)

[x] P3-1: Boost Clic — achat, appliqué
[x] P3-2: Ouvrière départ — achat, appliqué au restart
[x] P3-3: Miel départ — achat, appliqué au restart
[x] P3-4: Ruche + — achat, get_sante_ruche_max()
[x] P3-5: Slot ouvrière — achat, max ouvrière
[x] P3-6: Prime frelon — achat, récompense
[x] P3-7: Prime ours — achat, récompense
[x] P3-8: Guerrière + — achat, get_guerriere_max()
[x] P3-9: Boost capacité — achat, get_capacite_ouvriere()
[ ] P3-10: Refresh interface après achat

## PRIORITÉ 4 — ÉCRANS ET UI

[x] P4-1: Game Over — carte upgrades cliquables
[x] P4-2: Assemblée — fond, process_mode, vote
[ ] P4-3: Upgrades — affichage niveaux corrects
[ ] P4-4: Musée — écran collection (placeholder)
[ ] P4-5: Menu — crédits, bouton collection

## PRIORITÉ 5 — ARCHITECTURE

[x] P5-1: Centraliser PESTICIDE_IDS dans GameManager
[ ] P5-2: Centraliser SHOP_ITEMS dans GameManager
[ ] P5-3: Supprimer ShopScreen orphelin
[ ] P5-4: Supprimer code mort (reines_repliques, t inutilisé)
[ ] P5-5: Split Main.gd → BeeManager, FlowerManager, etc.

## PRIORITÉ 6 — CONTENU

[ ] P6-1: Biomes — 8 fonds distincts (prompts ChatGPT)
[ ] P6-2: Sprites — nouvelles fleurs, ennemis
[ ] P6-3: Spécialisations ouvrières — butineuse, gardienne, etc.
[ ] P6-4: Mutations reines — système de générations
[ ] P6-5: Collection — 30+ entrées à découvrir
[ ] P6-6: Événements manquants — canicule, pluie, ours_dodo

## PRIORITÉ 7 — ÉQUILIBRAGE

[ ] P7-1: Coûts upgrades — calibrer courbes
[ ] P7-2: Temps de partie — prolongeable via choix
[ ] P7-3: Ennemis — fenêtre aléatoire ±15s
[ ] P7-4: Dollars — taux de conversion

## BUGS CONNUS

[x] B1: Événements auto-annulés (timer_evenement reset)
[x] B2: Boutons Voter sans signal
[x] B3: Double restart (GameOver + Main)
[x] B4: Ouvrières disparues au load
[x] B5: Prestige non appliqué
[x] B6: Achats clic gratuits
[x] B7: Guerrière + manquant dans acheter_shop
[x] B8: Match blocks mal indentés (x3)
[ ] B9: Affichage HP frelon incorrect si transversal
[ ] B10: _changer_biome — tous les fonds identiques
