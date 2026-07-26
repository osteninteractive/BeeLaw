extends Node

var _pass = 0
var _fail = 0
var _errors = []

func _ready():
	GameManager.set_save_path("user://beelaw_test_bcj.save")
	_clean_save()
	
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	prints("TESTS BEELAW B-C-J (complementaires)")
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	
	test_B_reset_menu()
	test_C_restart_conservation()
	test_J_reset_fermeture()
	
	prints("=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=", "=")
	prints("RESULTATS B-C-J:", str(_pass), "passes,", str(_fail), "echecs")
	if _fail > 0:
		prints("ERREURS:")
		for e in _errors: prints("  X", e)
	
	_clean_save()
	get_tree().quit(_fail)

func _clean_save():
	var test_path = ProjectSettings.globalize_path("user://beelaw_test_bcj.save")
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)

func _reset_state():
	GameManager.set_save_path("user://beelaw_test_bcj.save")
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
		prints("  OK", test_name)
	else:
		_fail += 1
		var m = "FAIL " + test_name
		if detail != "": m += " - " + detail
		_errors.append(m)
		prints("  FAIL", test_name, detail)

# ============================================================
# SCENARIO B - Reset depuis le menu
# 1. Acheter des upgrades et des ouvrieres
# 2. Cliquer sur Reset dans le menu (= reset_all_progress)
# 3. Sans fermer le jeu, lancer une nouvelle partie (reinit state)
# 4. Verifier: Miel=0, Pollen=0, Ouvrieres=0, Puissance=1,
#    Max=5/9, shop vide, stats 0
# ============================================================
func test_B_reset_menu():
	prints("--- SCENARIO B: Reset depuis le menu ---")
	_reset_state()
	GameManager.honey = 100000
	
	# 1. Acheter des upgrades et ouvrieres
	GameManager.acheter_clic()
	GameManager.acheter_clic()            # niveau_clic=2
	GameManager.acheter_ouvriere()        # ouvrieres=1
	GameManager.acheter_ouvriere()        # ouvrieres=2
	GameManager.acheter_max_butineuse()   # niveau_max_butineuse=1
	GameManager.acheter_vitesse_click()   # niveau_vitesse_click=1
	
	GameManager.honey = 100000
	GameManager.acheter_vitesse_ouvriere() # niveau_vitesse=1
	GameManager.acheter_capacite_ouvriere() # niveau_capacite=1
	GameManager.shop_niveaux["boost_clic"] = 5
	GameManager.shop_niveaux["miel_depart"] = 3
	GameManager.pollen = 200
	GameManager.stats.miel_produit = 10000
	GameManager.stats.parties = 5
	
	prints("  [INFO] Avant Reset: miel=" + str(GameManager.honey) +
	       " pollen=" + str(GameManager.pollen) +
	       " ouvrieres=" + str(GameManager.ouvrieres) +
	       " clic=" + str(GameManager.niveau_clic) +
	       " shop=" + str(GameManager.shop_niveaux.size()))
	
	# 2. Reset (Menu.gd appelle reset_all_progress)
	GameManager.reset_all_progress()
	
	# 3. Verifier l'etat apres reset (sans fermer le jeu)
	ok("B.1 Miel=0", GameManager.honey == 0, "got " + str(GameManager.honey))
	ok("B.2 Pollen=0", GameManager.pollen == 0, "got " + str(GameManager.pollen))
	ok("B.3 Ouvrieres=0", GameManager.ouvrieres == 0, "got " + str(GameManager.ouvrieres))
	
	var puis = GameManager.get_puissance_clic()
	ok("B.4 Puissance clic=1", puis == 1, "got " + str(puis))
	
	var max_ouv = GameManager.get_max_ouvrieres()
	ok("B.5 Max ouvrieres=5", max_ouv == 5, "got " + str(max_ouv))
	
	var max_but = GameManager.get_max_butineuse()
	ok("B.6 Max butineuses=9", max_but == 9, "got " + str(max_but))
	
	ok("B.7 Shop vide", GameManager.shop_niveaux.is_empty(),
	   "taille=" + str(GameManager.shop_niveaux.size()))
	
	ok("B.8 Stats zero", GameManager.stats.miel_produit == 0 and GameManager.stats.parties == 0,
	   "miel_produit=" + str(GameManager.stats.miel_produit) +
	   " parties=" + str(GameManager.stats.parties))
	
	ok("B.9 niveau_clic=0", GameManager.niveau_clic == 0, "got " + str(GameManager.niveau_clic))
	ok("B.10 niveau_max_butineuse=0", GameManager.niveau_max_butineuse == 0,
	   "got " + str(GameManager.niveau_max_butineuse))
	
	# 4. Simulation "lancer une nouvelle partie" = recharger la scene
	# (Dans le code reel, Menu.gd appelle change_scene_to_file -> Main.tscn
	#  qui cree un nouveau BeeManager, etc.)
	# On ne peut pas tester l'UI ici, mais on verifie que l'etat memoire est propre.

# ============================================================
# SCENARIO C - Restart (conservation des donnees)
# 1. Progresser puis utiliser Restart
# 2. Verifier: Ouvrieres=0, butineuses temporaires reinitialisees
# 3. Quelles donnees sont conservees?
#    - pollen? shop_niveaux? niveau_max_butineuse? generation?
# ============================================================
func test_C_restart_conservation():
	prints("--- SCENARIO C: Restart (conservation) ---")
	_reset_state()
	GameManager.honey = 50000
	
	# 1. Progresser
	GameManager.acheter_ouvriere()
	GameManager.acheter_ouvriere()      # ouvrieres=2
	GameManager.acheter_clic()          # niveau_clic=1
	GameManager.acheter_max_butineuse() # niveau=1 → max=10
	GameManager.shop_niveaux["boost_clic"] = 2
	GameManager.shop_niveaux["miel_depart"] = 4
	GameManager.shop_niveaux["boost_capacite"] = 1
	GameManager.pollen = 300
	
	# Avant restart
	var pollen_avant = GameManager.pollen
	var shop_avant = GameManager.shop_niveaux.duplicate(true)
	var gen_avant = GameManager.generation
	var max_but_avant = GameManager.get_max_butineuse()  # 10
	var niv_max_but_avant = GameManager.niveau_max_butineuse  # 1
	
	prints("  [INFO] Avant Restart:")
	prints("    pollen=" + str(pollen_avant))
	prints("    shop_niveaux=" + str(shop_avant))
	prints("    generation=" + str(gen_avant))
	prints("    max_butineuses=" + str(max_but_avant))
	prints("    niveau_max_butineuse=" + str(niv_max_but_avant))
	prints("    ouvrieres=" + str(GameManager.ouvrieres))
	
	# 2. Restart
	GameManager.restart()
	
	# 3. Analyse de ce qui est conserve
	prints("  [INFO] Apres Restart:")
	prints("    ouvrieres=" + str(GameManager.ouvrieres))
	prints("    niveau_clic=" + str(GameManager.niveau_clic))
	prints("    pollen=" + str(GameManager.pollen))
	prints("    shop_niveaux=" + str(GameManager.shop_niveaux))
	prints("    generation=" + str(GameManager.generation))
	prints("    max_butineuses=" + str(GameManager.get_max_butineuse()))
	prints("    niveau_max_butineuse=" + str(GameManager.niveau_max_butineuse))
	
	# Verifications
	ok("C.1 Ouvrieres=0", GameManager.ouvrieres == 0, "got " + str(GameManager.ouvrieres))
	ok("C.2 niveau_clic=0", GameManager.niveau_clic == 0, "got " + str(GameManager.niveau_clic))
	ok("C.3 pollen conserve", GameManager.pollen == pollen_avant,
	   "avant=" + str(pollen_avant) + " apres=" + str(GameManager.pollen))
	ok("C.4 shop_niveaux conserve", GameManager.shop_niveaux.get("boost_clic", 0) == 2,
	   "got=" + str(GameManager.shop_niveaux.get("boost_clic", 0)))
	ok("C.5 generation incremente", GameManager.generation == gen_avant + 1,
	   "avant=" + str(gen_avant) + " apres=" + str(GameManager.generation))
	
	# NOTE: niveau_max_butineuse n'est PAS dans restart()
	# Il est donc conserve entre les runs
	ok("C.6 niveau_max_butineuse conserve", GameManager.niveau_max_butineuse == niv_max_but_avant,
	   "avant=" + str(niv_max_but_avant) + " apres=" + str(GameManager.niveau_max_butineuse))

# ============================================================
# SCENARIO J - Reset total avec fermeture
# 1. Acheter upgrades, reset, sauver
# 2. Simuler fermeture/relance: ecraser memoire puis reload
# 3. Verifier Miel=Pollen=0, tout a zero
# ============================================================
func test_J_reset_fermeture():
	prints("--- SCENARIO J: Reset total + fermeture/relance ---")
	_reset_state()
	GameManager.honey = 100000
	
	# 1. Acheter des upgrades
	GameManager.acheter_clic()
	GameManager.acheter_ouvriere()
	GameManager.acheter_max_butineuse()
	GameManager.shop_niveaux["boost_clic"] = 5
	GameManager.shop_niveaux["miel_depart"] = 3
	GameManager.pollen = 150
	GameManager.stats.miel_produit = 5000
	GameManager.stats.parties = 3
	
	prints("  [INFO] Avant Reset: miel=" + str(GameManager.honey) +
	       " pollen=" + str(GameManager.pollen) +
	       " shop=" + str(GameManager.shop_niveaux))
	
	# 2. Reset total (supprime sauvegarde + reinitialise)
	GameManager.reset_all_progress()
	
	# Verifier apres reset (avant fermeture)
	ok("J.1 Apres reset: Miel=0", GameManager.honey == 0, "got " + str(GameManager.honey))
	ok("J.2 Apres reset: Pollen=0", GameManager.pollen == 0, "got " + str(GameManager.pollen))
	
	# Verifier que la sauvegarde a ete supprimee
	var save_path = ProjectSettings.globalize_path("user://beelaw_test_bcj.save")
	ok("J.3 Fichier save supprime", not FileAccess.file_exists(save_path),
	   "fichier existe: " + str(FileAccess.file_exists(save_path)))
	
	# 3. Simuler fermeture et relance
	# Apres reset_all_progress, la sauvegarde est detruite.
	# Au prochain lancement reel, GameManager._ready() appelle load_save()
	# qui ne trouve rien: retourne sans modifier -> tout reste aux valeurs par defaut.
	# On simule le relancement: on remet tout aux valeurs par defaut
	# puis on appelle load_save() (qui ne trouvera rien et ne changera rien).
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
	GameManager.shop_niveaux = {}
	GameManager.generation = 1
	GameManager.niveau_reine = 1
	GameManager.mutations = {}
	GameManager.biome_actuel = 0
	GameManager.lois_votees = {}
	GameManager.deputes = 0
	GameManager.stats = GameManager.STATS_DEFAULTS.duplicate(true)
	GameManager.collection_decouverte = {}
	GameManager.collection_progression = {}
	
	# Reload (simule _ready() du relancement)
	GameManager.load_save()
	
	# 4. Verifier tout a zero
	ok("J.4 Reload: Miel=0", GameManager.honey == 0, "got " + str(GameManager.honey))
	ok("J.5 Reload: Pollen=0", GameManager.pollen == 0, "got " + str(GameManager.pollen))
	ok("J.6 Reload: Ouvrieres=0", GameManager.ouvrieres == 0, "got " + str(GameManager.ouvrieres))
	
	var puis = GameManager.get_puissance_clic()
	ok("J.7 Reload: Puissance=1", puis == 1, "got " + str(puis))
	
	var max_ouv = GameManager.get_max_ouvrieres()
	ok("J.8 Reload: Max ouvrieres=5", max_ouv == 5, "got " + str(max_ouv))
	
	var max_but = GameManager.get_max_butineuse()
	ok("J.9 Reload: Max butineuses=9", max_but == 9, "got " + str(max_but))
	
	ok("J.10 Reload: Shop vide", GameManager.shop_niveaux.is_empty(),
	   "taille=" + str(GameManager.shop_niveaux.size()))
	
	ok("J.11 Reload: Stats zero", GameManager.stats.miel_produit == 0,
	   "miel_produit=" + str(GameManager.stats.miel_produit))
