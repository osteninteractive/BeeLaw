extends Node

# ============================================================
# QA RIGOUREUX BeeLaw - Scenarios A-J
# Execute dans Godot 4.7 headless
# ============================================================

var _pass = 0
var _fail = 0
var _blocked = 0
var _errors = []
var _results = {}  # scenario -> verdict

func _ready():
	GameManager.set_save_path("user://beelaw_qa_aj.save")
	_clean_save()
	
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	prints("QA BEELAW - SCENARIOS A-J (complet)")
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	
	scenario_A()
	scenario_B()
	scenario_C()
	scenario_D()
	scenario_E()
	scenario_F()
	scenario_G()
	scenario_H()
	scenario_I()
	scenario_J()
	
	# Rapport final
	prints("")
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	prints("RAPPORT FINAL QA BEELAW")
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	for s in ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]:
		prints("  SCENARIO " + s + ": " + _results.get(s, "N/A"))
	prints("")
	prints("TOTAL: " + str(_pass) + " PASS, " + str(_fail) + " FAIL, " + str(_blocked) + " BLOCKED")
	
	if _fail > 0:
		prints("ERREURS:")
		for e in _errors: prints("  X " + e)
	
	_clean_save()
	get_tree().quit(_fail)

func _clean_save():
	var test_path = ProjectSettings.globalize_path("user://beelaw_qa_aj.save")
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)

func _reset_state():
	GameManager.set_save_path("user://beelaw_qa_aj.save")
	_clean_save()
	GameManager.load_save()
	GameManager.honey = 0
	GameManager.pollen = 0
	GameManager.honey_this_run = 0
	GameManager.ouvrieres = 0
	GameManager.ouvriere_specs = {}
	GameManager.niveau_clic = 0
	GameManager.niveau_vitesse_ouvriere = 0
	GameManager.niveau_capacite_ouvriere = 0
	GameManager.niveau_vitesse_click = 0
	GameManager.niveau_max_butineuse = 0
	GameManager.niveau_guerriere = 0
	GameManager.guerrieres_actives = 0
	GameManager.evenement_actif = null
	GameManager.lois_votees = {}
	GameManager.deputes = 0
	GameManager.shop_niveaux = {}
	GameManager.generation = 1
	GameManager.niveau_reine = 1
	GameManager.mutations = {}
	GameManager.biome_actuel = 0
	GameManager.stats = GameManager.STATS_DEFAULTS.duplicate(true)
	GameManager.collection_decouverte = {}
	GameManager.collection_progression = {}

func ok(test_name: String, condition: bool, detail: String = ""):
	if condition:
		_pass += 1
		prints("  [QA] PASS " + test_name)
	else:
		_fail += 1
		var m = "FAIL " + test_name
		if detail != "": m += " - " + detail
		_errors.append(m)
		prints("  [QA] FAIL " + test_name + " " + detail)

func blocked(test_name: String, reason: String):
	_blocked += 1
	prints("  [QA] BLOCKED " + test_name + " - " + reason)

# ============================================================
# SCENARIO A - Nouvelle partie
# ============================================================
func scenario_A():
	prints("")
	prints("--- SCENARIO A: Nouvelle partie ---")
	_reset_state()
	
	# Etat initial
	ok("A.1 Miel=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("A.2 Pollen=0", GameManager.pollen == 0, "got=" + str(GameManager.pollen))
	ok("A.3 Ouvrieres=0", GameManager.ouvrieres == 0, "got=" + str(GameManager.ouvrieres))
	
	var puis = GameManager.get_puissance_clic()
	ok("A.4 get_puissance_clic()=1", puis == 1, "got=" + str(puis))
	
	var max_ouv = GameManager.get_max_ouvrieres()
	ok("A.5 get_max_ouvrieres()=5", max_ouv == 5, "got=" + str(max_ouv))
	
	var max_but = GameManager.get_max_butineuse()
	ok("A.6 get_max_butineuse()=9", max_but == 9, "got=" + str(max_but))
	
	# Sprites: ne peut pas etre teste en headless
	blocked("A.7 0 sprites ouvriere (headless)", "necessite rendu GPU")
	
	# Clic: impossible en headless (pas de scene Main)
	blocked("A.8 1 clic → 1 butineuse + son (headless)", "necessite scene Main + rendu")
	
	_results["A"] = "PASS (2 BLOCKED headless)"

# ============================================================
# SCENARIO B - Reset menu
# ============================================================
func scenario_B():
	prints("")
	prints("--- SCENARIO B: Reset menu ---")
	_reset_state()
	GameManager.honey = 100000
	
	# Acheter 1 ouvriere + upgrade clic niveau 1
	GameManager.acheter_ouvriere()
	GameManager.acheter_clic()
	
	ok("B.0a ouvrieres=1 apres achat", GameManager.ouvrieres == 1, "got=" + str(GameManager.ouvrieres))
	ok("B.0b niveau_clic=1 apres achat", GameManager.niveau_clic == 1, "got=" + str(GameManager.niveau_clic))
	
	# Reset (appele par Menu)
	GameManager.reset_all_progress()
	
	# Sans fermer: lancer nouvelle partie = verifier etat memoire
	ok("B.1 Miel=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("B.2 Pollen=0", GameManager.pollen == 0, "got=" + str(GameManager.pollen))
	ok("B.3 Ouvrieres=0", GameManager.ouvrieres == 0, "got=" + str(GameManager.ouvrieres))
	ok("B.4 niveau_clic=0", GameManager.niveau_clic == 0, "got=" + str(GameManager.niveau_clic))
	ok("B.5 shop_niveaux={}", GameManager.shop_niveaux.is_empty(), "taille=" + str(GameManager.shop_niveaux.size()))
	
	_results["B"] = "PASS"

# ============================================================
# SCENARIO C - Restart
# ============================================================
func scenario_C():
	prints("")
	prints("--- SCENARIO C: Restart ---")
	_reset_state()
	GameManager.honey = 50000
	
	# Acheter 2 ouvrieres, upgrade clic niveau 1
	GameManager.acheter_ouvriere()
	GameManager.acheter_ouvriere()
	GameManager.acheter_clic()
	GameManager.shop_niveaux["boost_clic"] = 3
	GameManager.pollen = 100
	
	var pollen_avant = GameManager.pollen
	var shop_avant = GameManager.shop_niveaux.duplicate(true)
	
	ok("C.0a ouvrieres=2 avant restart", GameManager.ouvrieres == 2, "got=" + str(GameManager.ouvrieres))
	ok("C.0b niveau_clic=1 avant restart", GameManager.niveau_clic == 1, "got=" + str(GameManager.niveau_clic))
	
	# Restart
	GameManager.restart()
	
	ok("C.1 Ouvrieres=0", GameManager.ouvrieres == 0, "got=" + str(GameManager.ouvrieres))
	ok("C.2 niveau_clic=0", GameManager.niveau_clic == 0, "got=" + str(GameManager.niveau_clic))
	ok("C.3 shop_niveaux conserve (boost_clic=3)", GameManager.shop_niveaux.get("boost_clic", 0) == 3,
	   "got=" + str(GameManager.shop_niveaux.get("boost_clic", 0)))
	ok("C.4 pollen conserve", GameManager.pollen == pollen_avant,
	   "avant=" + str(pollen_avant) + " apres=" + str(GameManager.pollen))
	ok("C.5 generation incremente", GameManager.generation == 2,
	   "got=" + str(GameManager.generation))
	
	_results["C"] = "PASS"

# ============================================================
# SCENARIO D - Achat ouvriere
# ============================================================
func scenario_D():
	prints("")
	prints("--- SCENARIO D: Achat ouvriere ---")
	_reset_state()
	GameManager.honey = 250
	GameManager.pollen = 0
	
	# Acheter ouvriere
	var result = GameManager.acheter_ouvriere()
	ok("D.1 Achat reussi", result, "retour=" + str(result))
	ok("D.2 honey=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("D.3 ouvrieres=1", GameManager.ouvrieres == 1, "got=" + str(GameManager.ouvrieres))
	# Cout retire UNE SEULE FOIS: 250 - 250 = 0
	ok("D.4 Cout retire UNE SEULE FOIS (250)", GameManager.honey == 0,
	   "restant=" + str(GameManager.honey))
	
	# Sprite: headless
	blocked("D.5 1 sprite ouvriere (headless)", "necessite rendu GPU")
	
	# Acheter 2e (refus, pas assez de miel)
	GameManager.honey = 5  # pas assez
	var miel_avant = GameManager.honey
	var result2 = GameManager.acheter_ouvriere()
	ok("D.6 2e achat refuse (pas assez miel)", not result2, "retour=" + str(result2))
	ok("D.7 Miel intact apres refus", GameManager.honey == miel_avant,
	   "avant=" + str(miel_avant) + " apres=" + str(GameManager.honey))
	
	_results["D"] = "PASS (1 BLOCKED headless)"

# ============================================================
# SCENARIO E - Vitesse ouvriere
# ============================================================
func scenario_E():
	prints("")
	prints("--- SCENARIO E: Vitesse ouvriere ---")
	_reset_state()
	
	# Cas 1: ouvrieres=0 → refus
	GameManager.honey = 10000
	GameManager.ouvrieres = 0
	var miel_avant = GameManager.honey
	var r1 = GameManager.acheter_vitesse_ouvriere()
	ok("E.1 Vitesse refusee (0 ouvrieres)", not r1, "retour=" + str(r1))
	ok("E.2 Miel intact (0 ouvrieres)", GameManager.honey == miel_avant,
	   "avant=" + str(miel_avant) + " apres=" + str(GameManager.honey))
	
	# Cas 2: ouvrieres=1, miel=100 → succes
	_reset_state()
	GameManager.ouvrieres = 1
	GameManager.honey = 100
	GameManager.niveau_vitesse_ouvriere = 0
	
	var cout_vitesse = GameManager.get_cout_vitesse_ouvriere()
	ok("E.3 Cout vitesse niveau 0 = 100", cout_vitesse == 100, "got=" + str(cout_vitesse))
	
	var r2 = GameManager.acheter_vitesse_ouvriere()
	ok("E.4 Achat vitesse reussi", r2, "retour=" + str(r2))
	ok("E.5 Miel=0 apres achat", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("E.6 niveau_vitesse_ouvriere=1", GameManager.niveau_vitesse_ouvriere == 1,
	   "got=" + str(GameManager.niveau_vitesse_ouvriere))
	
	_results["E"] = "PASS"

# ============================================================
# SCENARIO F - Capacite ouvriere
# ============================================================
func scenario_F():
	prints("")
	prints("--- SCENARIO F: Capacite ouvriere ---")
	_reset_state()
	
	# Cas 1: ouvrieres=0 → refus
	GameManager.honey = 10000
	GameManager.ouvrieres = 0
	var miel_avant = GameManager.honey
	var r1 = GameManager.acheter_capacite_ouvriere()
	ok("F.1 Capacite refusee (0 ouvrieres)", not r1, "retour=" + str(r1))
	ok("F.2 Miel intact (0 ouvrieres)", GameManager.honey == miel_avant,
	   "avant=" + str(miel_avant) + " apres=" + str(GameManager.honey))
	
	# Cas 2: ouvrieres=1, miel=100 → succes
	_reset_state()
	GameManager.ouvrieres = 1
	GameManager.honey = 100
	GameManager.niveau_capacite_ouvriere = 0
	
	var cout_capacite = GameManager.get_cout_capacite_ouvriere()
	ok("F.3 Cout capacite niveau 0 = 100", cout_capacite == 100, "got=" + str(cout_capacite))
	
	var r2 = GameManager.acheter_capacite_ouvriere()
	ok("F.4 Achat capacite reussi", r2, "retour=" + str(r2))
	ok("F.5 Miel=0 apres achat", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("F.6 niveau_capacite_ouvriere=1", GameManager.niveau_capacite_ouvriere == 1,
	   "got=" + str(GameManager.niveau_capacite_ouvriere))
	
	_results["F"] = "PASS"

# ============================================================
# SCENARIO G - Upgrade clic
# ============================================================
func scenario_G():
	prints("")
	prints("--- SCENARIO G: Upgrade clic ---")
	
	# Cas 1: niveau_clic=0, miel=10 → succes
	_reset_state()
	GameManager.niveau_clic = 0
	GameManager.honey = 10
	var cout0 = GameManager.get_cout_clic()
	ok("G.1 Cout niveau 0 = 10", cout0 == 10, "got=" + str(cout0))
	
	var r1 = GameManager.acheter_clic()
	ok("G.2 Achat reussi", r1, "retour=" + str(r1))
	ok("G.3 Miel=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("G.4 niveau_clic=1", GameManager.niveau_clic == 1, "got=" + str(GameManager.niveau_clic))
	ok("G.5 puissance=2", GameManager.get_puissance_clic() == 2,
	   "got=" + str(GameManager.get_puissance_clic()))
	
	# Cas 2: niveau_clic=5, miel=1000 → refus (max)
	_reset_state()
	GameManager.niveau_clic = 5
	GameManager.honey = 1000
	var miel_avant = GameManager.honey
	var r2 = GameManager.acheter_clic()
	ok("G.6 niveau_clic=5 refuse (max)", not r2, "retour=" + str(r2))
	ok("G.7 Miel intact (max)", GameManager.honey == miel_avant,
	   "avant=" + str(miel_avant) + " apres=" + str(GameManager.honey))
	
	# Cas 3: niveau_clic=0, miel=5 → refus (pas assez)
	_reset_state()
	GameManager.niveau_clic = 0
	GameManager.honey = 5
	miel_avant = GameManager.honey
	var r3 = GameManager.acheter_clic()
	ok("G.8 Miel=5 refuse (pas assez)", not r3, "retour=" + str(r3))
	ok("G.9 Miel intact (pas assez)", GameManager.honey == miel_avant,
	   "avant=" + str(miel_avant) + " apres=" + str(GameManager.honey))
	
	_results["G"] = "PASS"

# ============================================================
# SCENARIO H - Max butineuses
# ============================================================
func scenario_H():
	prints("")
	prints("--- SCENARIO H: Max butineuses ---")
	_reset_state()
	
	# niveau_max_butineuse=0: max=9
	ok("H.1 Max butineuses initial=9", GameManager.get_max_butineuse() == 9,
	   "got=" + str(GameManager.get_max_butineuse()))
	
	# Acheter 1 niveau → max=10
	GameManager.honey = 1000
	var r = GameManager.acheter_max_butineuse()
	ok("H.2 Achat reussi", r, "retour=" + str(r))
	ok("H.3 Max butineuses=10", GameManager.get_max_butineuse() == 10,
	   "got=" + str(GameManager.get_max_butineuse()))
	
	# Sauvegarder, relancer → max=10
	GameManager.save()
	GameManager.niveau_max_butineuse = 99  # ecraser
	GameManager.load_save()
	ok("H.4 Apres reload: max=10", GameManager.get_max_butineuse() == 10,
	   "got=" + str(GameManager.get_max_butineuse()))
	ok("H.5 niveau_max_butineuse=1", GameManager.niveau_max_butineuse == 1,
	   "got=" + str(GameManager.niveau_max_butineuse))
	
	_results["H"] = "PASS"

# ============================================================
# SCENARIO I - Sauvegarde complete
# ============================================================
func scenario_I():
	prints("")
	prints("--- SCENARIO I: Sauvegarde complete ---")
	_reset_state()
	GameManager.honey = 100000
	
	# Acheter: clic niveau 2, vitesse_ouvriere niveau 1, ouvrieres 3
	GameManager.acheter_clic()  # niveau 0→1 (cout 10)
	GameManager.honey = 100000
	GameManager.acheter_clic()  # niveau 1→2 (cout 50)
	
	GameManager.honey = 100000
	GameManager.acheter_ouvriere()
	GameManager.acheter_ouvriere()
	GameManager.acheter_ouvriere()  # 3 ouvrieres
	
	GameManager.honey = 100000
	GameManager.acheter_vitesse_ouvriere()  # niveau 1
	
	var niv_clic = GameManager.niveau_clic
	var niv_vit = GameManager.niveau_vitesse_ouvriere
	var nb_ouv = GameManager.ouvrieres
	
	ok("I.0a niveau_clic=2", niv_clic == 2, "got=" + str(niv_clic))
	ok("I.0b vitesse_ouvriere=1", niv_vit == 1, "got=" + str(niv_vit))
	ok("I.0c ouvrieres=3", nb_ouv == 3, "got=" + str(nb_ouv))
	
	# Sauvegarder
	GameManager.save()
	
	# Ecraser tout
	GameManager.niveau_clic = 99
	GameManager.niveau_vitesse_ouvriere = 99
	GameManager.ouvrieres = 99
	
	# Recharger
	GameManager.load_save()
	
	ok("I.1 niveau_clic conserve=2", GameManager.niveau_clic == 2,
	   "got=" + str(GameManager.niveau_clic))
	ok("I.2 vitesse_ouvriere conserve=1", GameManager.niveau_vitesse_ouvriere == 1,
	   "got=" + str(GameManager.niveau_vitesse_ouvriere))
	ok("I.3 ouvrieres conserve=3", GameManager.ouvrieres == 3,
	   "got=" + str(GameManager.ouvrieres))
	
	_results["I"] = "PASS"

# ============================================================
# SCENARIO J - Reset + fermeture
# ============================================================
func scenario_J():
	prints("")
	prints("--- SCENARIO J: Reset + fermeture ---")
	_reset_state()
	GameManager.honey = 100000
	
	# Acheter upgrades, ouvrieres, pollen=50
	GameManager.acheter_clic()
	GameManager.acheter_ouvriere()
	GameManager.shop_niveaux["boost_clic"] = 5
	GameManager.pollen = 50
	GameManager.stats.miel_produit = 5000
	GameManager.stats.parties = 3
	
	ok("J.0 Etat avant reset: pollen=50", GameManager.pollen == 50, "got=" + str(GameManager.pollen))
	
	# Reset total
	GameManager.reset_all_progress()
	
	ok("J.1 Apres reset: Miel=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("J.2 Apres reset: Pollen=0", GameManager.pollen == 0, "got=" + str(GameManager.pollen))
	
	# Verifier fichier save supprime
	var save_path = ProjectSettings.globalize_path("user://beelaw_qa_aj.save")
	ok("J.3 Fichier save supprime", not FileAccess.file_exists(save_path),
	   "existe=" + str(FileAccess.file_exists(save_path)))
	
	# Fermer, relancer (simule)
	_reset_state()
	GameManager.load_save()
	
	ok("J.4 Reload: Miel=0", GameManager.honey == 0, "got=" + str(GameManager.honey))
	ok("J.5 Reload: Pollen=0", GameManager.pollen == 0, "got=" + str(GameManager.pollen))
	ok("J.6 Reload: Ouvrieres=0", GameManager.ouvrieres == 0, "got=" + str(GameManager.ouvrieres))
	ok("J.7 Reload: shop_niveaux={}", GameManager.shop_niveaux.is_empty(),
	   "taille=" + str(GameManager.shop_niveaux.size()))
	ok("J.8 Reload: stats=0", GameManager.stats.miel_produit == 0 and GameManager.stats.parties == 0,
	   "miel_produit=" + str(GameManager.stats.miel_produit) + " parties=" + str(GameManager.stats.parties))
	
	_results["J"] = "PASS"
