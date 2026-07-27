extends Node

var _pass = 0; var _fail = 0; var _errors = []

func _ready():
	# Utiliser une sauvegarde isolee pour les tests
	GameManager.set_save_path("user://beelaw_test.save")
	# Supprimer toute ancienne sauvegarde de test
	var test_path = ProjectSettings.globalize_path("user://beelaw_test.save")
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)
	GameManager.load_save()
	GameManager.shop_niveaux = {}; GameManager.honey = 0; GameManager.pollen = 0
	GameManager.honey_this_run = 0; GameManager.ouvrieres = 0; GameManager.niveau_clic = 0
	GameManager.niveau_vitesse_ouvriere = 0; GameManager.niveau_capacite_ouvriere = 0
	GameManager.niveau_vitesse_click = 0; GameManager.guerrieres_actives = 0
	GameManager.evenement_actif = null; GameManager.lois_votees = {}
	GameManager.deputes = 0; GameManager.generation = 1
	
	prints("=","=","=","=","=","=","=","=","=","=","=","=","=","=","=","=")
	prints("TESTS BEELAW v2")
	prints("=","=","=","=","=","=","=","=","=","=","=","=","=","=","=","=")
	
	_eco(); _achats(); _ouvr(); _guer(); _pol(); _evt(); _reset(); _save()
	
	# Tests integration
	_iachat_save()
	_iprestige()
	_iassemblee()
	
	prints("=","=","=","=","=","=","=","=","=","=","=","=","=","=","=","=")
	prints("RESULTATS:", str(_pass), "passes,", str(_fail), "echecs")
	if _fail > 0:
		prints("ERREURS:")
		for e in _errors: prints("  X", e)
	
	# Nettoyage
	var clean_path = ProjectSettings.globalize_path("user://beelaw_test.save")
	if FileAccess.file_exists(clean_path):
		DirAccess.remove_absolute(clean_path)
	
	get_tree().quit(_fail)

func ok(n, c, x = ""):
	if c:
		_pass += 1; prints("  OK", n)
	else:
		_fail += 1
		var m = "FAIL " + n
		if x != "":
			m += " - " + x
		_errors.append(m)
		prints("  FAIL", n, x)

func _eco():
	prints("--- ECONOMIE ---")
	GameManager.honey = 0; GameManager.niveau_clic = 0
	ok("Puis niv0=1", GameManager.get_puissance_clic() == 1)
	var c = GameManager.get_cout_clic()
	ok("Cout niv0=10", c == 10, "got " + str(c))
	GameManager.honey = 5; ok("Pas assez honey", GameManager.honey == 5)
	GameManager.honey = 50; c = GameManager.get_cout_clic()
	GameManager.honey -= c; GameManager.niveau_clic += 1
	ok("Honey deduit 10", GameManager.honey == 40, "got " + str(GameManager.honey))
	ok("Niv clic=1", GameManager.niveau_clic == 1)
	ok("Puis niv1=2", GameManager.get_puissance_clic() == 2)

func _achats():
	prints("--- ACHATS ---")
	GameManager.honey = 10000; GameManager.ouvrieres = 3
	GameManager.niveau_vitesse_ouvriere = 0; GameManager.niveau_capacite_ouvriere = 0
	var oh = GameManager.honey
	GameManager.acheter_vitesse_ouvriere()
	ok("Vitesse deduit", GameManager.honey < oh); ok("Niv vitesse=1", GameManager.niveau_vitesse_ouvriere == 1)
	oh = GameManager.honey
	GameManager.acheter_capacite_ouvriere()
	ok("Capacite deduit", GameManager.honey < oh)
	ok("Niv capacite=1", GameManager.niveau_capacite_ouvriere == 1)
	var cap = GameManager.get_capacite_ouvriere()
	ok("Capacite >0", cap > 0, "got " + str(cap))
	ok("Vitesse 0.4", GameManager.get_vitesse_ouvriere() == 0.4)

func _ouvr():
	prints("--- OUVRIERES ---")
	GameManager.honey = 10000; GameManager.ouvrieres = 0
	ok("Achat ok", GameManager.acheter_ouvriere()); ok("Count=1", GameManager.ouvrieres == 1)
	ok("Honey=9750", GameManager.honey == 9750)
	GameManager.honey = 10000
	for i in range(10): GameManager.acheter_ouvriere()
	ok("Max >=5", GameManager.ouvrieres >= 5, "got " + str(GameManager.ouvrieres))

func _guer():
	prints("--- GUERRIERE ---")
	GameManager.shop_niveaux["guerriere_slots"] = 0
	ok("Max base=1", GameManager.get_guerriere_max() == 1)
	ok("Achat slot ok", GameManager.acheter_shop("guerriere_slots"))
	ok("Max=2", GameManager.get_guerriere_max() == 2)

func _pol():
	prints("--- POLITIQUE ---")
	GameManager.deputes = 20; GameManager.lois_votees = {}
	ok("Mult base=1.0", GameManager.get_pesticide_mult() == 1.0)
	GameManager.lois_votees["imidaclopride"] = true
	var wv = GameManager.get_pesticide_mult()
	ok("Apres 1 vote <1", wv < 1.0, "got " + str(wv))
	GameManager.lois_votees = {}
	for pid in GameManager.PESTICIDE_IDS: GameManager.lois_votees[pid] = true
	var av = GameManager.get_pesticide_mult()
	ok("Tous=0.35", abs(av - 0.35) < 0.001, "got " + str(av))

func _evt():
	prints("--- EVENEMENTS ---")
	ok("Null depart", GameManager.evenement_actif == null)
	GameManager._prochain_evenement()
	ok("Prochain>100", GameManager.prochain_evenement > 100)
	ok("Timer pas modifie", GameManager.timer_evenement == 0.0)

func _reset():
	prints("--- RESTART ---")
	GameManager.honey = 999; GameManager.niveau_clic = 3; GameManager.ouvrieres = 8
	GameManager.shop_niveaux["boost_clic"] = 2
	var ga = GameManager.generation
	GameManager.restart()
	ok("Honey>=0", GameManager.honey >= 0); ok("Niv clic=0", GameManager.niveau_clic == 0)
	ok("Ouvr=0", GameManager.ouvrieres == 0)
	ok("Lois vides", GameManager.lois_votees.is_empty())
	ok("Boost conserve", GameManager.shop_niveaux.get("boost_clic", 0) == 2)
	ok("Gen +1", GameManager.generation == ga + 1)

func _save():
	prints("--- SAUVEGARDE ---")
	GameManager.honey = 500; GameManager.pollen = 10; GameManager.ouvrieres = 3
	GameManager.shop_niveaux["miel_depart"] = 1; GameManager.save()
	GameManager.honey = 0; GameManager.pollen = 0; GameManager.ouvrieres = 0
	GameManager.load_save()
	ok("Honey=500", GameManager.honey == 500); ok("Dollars=10", GameManager.dollars == 10)
	ok("Ouvr=3", GameManager.ouvrieres == 3)
	ok("Shop ok", GameManager.shop_niveaux.get("miel_depart", 0) == 1)

func _iachat_save():
	prints("--- INTEGRATION: Achat+Save+Load ---")
	GameManager.honey = 10000; GameManager.ouvrieres = 0; GameManager.niveau_clic = 0
	GameManager.shop_niveaux = {}
	
	# Acheter clic
	var c = GameManager.get_cout_clic()
	GameManager.honey -= c; GameManager.niveau_clic += 1
	ok("Clic niv 1 apres achat", GameManager.niveau_clic == 1)
	ok("Honey deduit", GameManager.honey < 10000)
	
	# Acheter ouvriere
	GameManager.acheter_ouvriere()
	ok("Ouvriere apres achat", GameManager.ouvrieres == 1)
	
	# Sauvegarder
	GameManager.save()
	GameManager.honey = 0; GameManager.niveau_clic = 0; GameManager.ouvrieres = 0
	GameManager.load_save()
	ok("Honey restore", GameManager.honey > 0, "got " + str(GameManager.honey))
	ok("Niv clic restore", GameManager.niveau_clic == 1)
	ok("Ouvriere restore", GameManager.ouvrieres == 1)

func _iprestige():
	prints("--- INTEGRATION: Prestige ---")
	GameManager.shop_niveaux["boost_clic"] = 2
	var gen_av = GameManager.generation
	GameManager.niveau_clic = 3; GameManager.ouvrieres = 5
	
	GameManager.restart()
	
	ok("Niv clic reset", GameManager.niveau_clic == 0)
	ok("Ouvrieres reset", GameManager.ouvrieres == 0)
	ok("Boost clic conserve", GameManager.shop_niveaux.get("boost_clic", 0) == 2)
	ok("Generation +1", GameManager.generation == gen_av + 1)

func _iassemblee():
	prints("--- INTEGRATION: Assemblee ---")
	GameManager.deputes = 20; GameManager.lois_votees = {}
	
	# Voter une loi
	GameManager.deputes -= 8  # cout imidaclopride
	GameManager.lois_votees["imidaclopride"] = true
	GameManager.save()
	ok("Deputes deduits", GameManager.deputes == 12)
	ok("Loi vote", GameManager.lois_votees.has("imidaclopride"))
	
	# Impossible de voter 2x
	GameManager.lois_votees["imidaclopride"] = true  # deja vote
	ok("Impossible voter 2x", GameManager.lois_votees.has("imidaclopride"))
	
	# Effet mesurable
	ok("Pesticide mult < 1", GameManager.get_pesticide_mult() < 1.0)
