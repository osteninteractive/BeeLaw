extends Node

const POWERS_ENABLED := false

signal honey_change(v)
signal pollen_change(v)
signal evenement(msg, duree)
signal biome_change(biome_id)
signal ouvriere_achetee

# ===================== STATS =====================
var stats = {
	"victoire": false,
	"miel_produit": 0,
	"miel_ouvrieres": 0, "abeilles_nes": 0,
	"frelons_tues": 0, "ours_repousses": 0,
	"fleurs_visitees": 0, "km_parcourus": 0.0,
	"clics_total": 0, "best_run": 0,
	"pollen_total": 0, "parties": 0
}

# ===================== RESSOURCES =====================
var honey: int = 0 : set = _set_honey
var jauge: float = 0.0
var pollen: int = 0 : set = _set_pollen
var honey_this_run: int = 0

# ===================== NIVEAUX UPGRADES =====================
var niveau_clic: int = 0
var niveau_vitesse_ouvriere: int = 0
var niveau_capacite_ouvriere: int = 0
var niveau_vitesse_click: int = 0
var niveau_guerriere: int = 0
var niveau_max_butineuse: int = 0
var guerrieres_actives: int = 0
var langue: String = "fr"
var _save_path_custom := ""

const STATS_DEFAULTS := {
	"miel_produit": 0, "miel_ouvrieres": 0, "abeilles_nes": 0,
	"frelons_tues": 0, "ours_repousses": 0, "fleurs_visitees": 0,
	"km_parcourus": 0.0, "clics_total": 0, "best_run": 0,
	"pollen_total": 0, "parties": 0, "victoire": false
}

func set_save_path(p: String):
	_save_path_custom = p

func _save_path() -> String:
	return _save_path_custom if _save_path_custom != "" else "user://beelaw.save"
const COUT_GUERRIERE: int = 200

func get_cout_clic() -> int: return 10 * int(pow(5, niveau_clic))
func get_cout_vitesse_ouvriere() -> int: return 100 * int(pow(5, niveau_vitesse_ouvriere))
func get_cout_capacite_ouvriere() -> int: return 100 * int(pow(5, niveau_capacite_ouvriere))
func get_cout_vitesse_click() -> int: return 10 * int(pow(5, niveau_vitesse_click))

func get_puissance_clic() -> int: return (1 << niveau_clic) + shop_niveaux.get("boost_clic", 0)
func get_vitesse_ouvriere() -> float: return [0.5, 0.4, 0.3, 0.22, 0.16, 0.1][clamp(niveau_vitesse_ouvriere, 0, 5)]
func get_max_butineuse() -> int: return 5 + niveau_max_butineuse
func get_cout_max_butineuse() -> int: return 500 * int(pow(3, niveau_max_butineuse))

func get_guerriere_cout() -> int:
	return 500 * int(pow(3, niveau_guerriere))

func get_vitesse_click() -> float: return [3.0, 2.5, 2.0, 1.5, 1.0, 0.5][clamp(niveau_vitesse_click, 0, 5)]

# ===================== REINE & GENERATIONS =====================
var niveau_reine: int = 1
var generation: int = 1
var mutations: Dictionary = {}  # {"id": niv}
const MUTATIONS_DISPONIBLES = [
	{"id": "rapide", "nom": "Abeilles +rapides", "desc": "Vol -15%", "max": 5},
	{"id": "riche", "nom": "Miel +riche", "desc": "Revenu +20%", "max": 5},
	{"id": "resistante", "nom": "R\u00e9sistance", "desc": "Pesticides -15%", "max": 5},
	{"id": "fleur_rare", "nom": "Fleurs rares", "desc": "Trouve + de fleurs rares", "max": 5},
	{"id": "gardienne", "nom": "Gardiennes +fortes", "desc": "D\u00e9g\u00e2ts x2", "max": 5},
]

# Skills cooldowns
var queen_skills = {
	"cri_royal": {"nom": "Cri Royal", "desc": "x2 vitesse 10s", "cooldown": 60, "timer": 0},
	"ponte": {"nom": "Nouvelle Ponte", "desc": "+5 ouvri\u00e8res", "cooldown": 120, "timer": 0},
	"essaim": {"nom": "Essaim", "desc": "x3 r\u00e9colte 8s", "cooldown": 90, "timer": 0},
}

# ===================== BIOMES =====================
var biome_actuel: int = 0
const BIOMES = [
	{"nom": "Prairie", "desc": "D\u00e9part classique", "honey_requis": 0, "couleur": Color(0.3, 0.7, 0.3)},
	{"nom": "Lavande", "desc": "Fleurs violettes, miel parfum\u00e9", "honey_requis": 5000, "couleur": Color(0.6, 0.3, 0.8)},
	{"nom": "Tournesols", "desc": "Grands champs jaunes", "honey_requis": 20000, "couleur": Color(0.9, 0.8, 0.1)},
	{"nom": "For\u00eat", "desc": "Ombrag\u00e9, fleurs rares", "honey_requis": 50000, "couleur": Color(0.1, 0.5, 0.2)},
	{"nom": "Montagne", "desc": "Altitude, flore alpine", "honey_requis": 150000, "couleur": Color(0.5, 0.5, 0.6)},
	{"nom": "Verger", "desc": "Arbres fruitiers", "honey_requis": 300000, "couleur": Color(0.8, 0.5, 0.2)},
	{"nom": "Colza", "desc": "Champs \u00e0 perte de vue", "honey_requis": 600000, "couleur": Color(0.9, 0.9, 0.2)},
	{"nom": "M\u00e9diterran\u00e9e", "desc": "Climat sec, oliviers", "honey_requis": 1000000, "couleur": Color(0.2, 0.6, 0.8)},
]

# ===================== FLEURS v2 =====================
const FLEURS_DATA = [
	["pissenlit", "Pissenlit", 0, 1, 1.0, 1, 3.0, 5, 3, "flower_dandelion"],
	["coquelicot", "Coquelicot", 0, 2, 1.2, 1, 4.0, 8, 5, "flower_coquelicot"],
	["marguerite", "Marguerite", 0, 2, 1.1, 1, 3.5, 12, 4, "flower_marguerite"],
	["lavande", "Lavande", 0, 5, 2.0, 2, 8.0, 20, 8, "flower_lavender"],
	["romarin", "Romarin", 0, 4, 1.8, 2, 7.0, 18, 6, "flower_romarin"],
	["tournesol", "Tournesol", 0, 8, 1.5, 3, 10.0, 30, 12, "flower_sunflower"],
	["digitale", "Digitale", 0, 6, 2.5, 3, 12.0, 35, 10, "flower_digitale"],
	["acacia", "Acacia", 0, 15, 3.0, 4, 20.0, 50, 20, "flower_acacia"],
	["edelweiss", "Edelweiss", 0, 10, 3.5, 5, 25.0, 80, 15, "flower_edelweiss"],
]

func get_fleur_data(idx):
	if idx < 0 or idx >= FLEURS_DATA.size(): return {}
	var f = FLEURS_DATA[idx]
	return {"id": f[0], "nom": f[1], "biome": f[2], "nectar": f[3], "pollen": f[4], "rarete": f[5], "temps_pousse": f[6], "pv_max": f[7], "sprite_id": f[9]}

func get_fleurs_biome(biome):
	var r = []
	for f in FLEURS_DATA:
		if f[2] <= biome: r.append(f)
	return r

# ===================== OUVRIERES v2 =====================
var ouvrieres: int = 0
var ouvriere_specs: Dictionary = {}  # {"butineuse": 0, "gardienne": 0, ...}
const COUT_OUVRIERE: int = 250
const MAX_OUVRIERES_BASE: int = 5
const MAX_OUVRIERES_TOTAL: int = 15
func get_guerriere_max() -> int: return 1 + shop_niveaux.get("guerriere_slots", 0)

func get_max_ouvrieres() -> int:
	return min(MAX_OUVRIERES_BASE + shop_niveaux.get("ouvriere_slots", 0), MAX_OUVRIERES_TOTAL)

const SPECIALISATIONS = {
	"butineuse": {"nom": "Butineuse", "desc": "R\u00e9colte x2", "icone": "🐝"},
	"gardienne": {"nom": "Gardienne", "desc": "Attaque ennemis", "icone": "⚔️"},
	"infirmiere": {"nom": "Infirmi\u00e8re", "desc": "Pesticides -50%", "icone": "💊"},
	"eclaireuse": {"nom": "\u00c9claireuse", "desc": "Fleurs rares", "icone": "🔍"},
	"architecte": {"nom": "Architecte", "desc": "Vie ruche +20%", "icone": "🏗️"},
}

# ===================== POLITIQUE =====================
var lois_votees: Dictionary = {}  # {"id": true}
const PESTICIDE_IDS: Array = ["imidaclopride", "clothianidine", "thiamethoxame", "acetamipride", "fipronil", "chlorpyriphos", "cypermethrine", "deltamethrine", "sulfoxaflor", "glyphosate", "mancozebe", "lambda", "paraquat"]
var deputes: int = 0

# Système politique base sur les 13 pesticides dans PESTICIDE_IDS, "nom": "Interdire glyphosate", "pour": "+15% sant\u00e9", "contre": "-20% pollen", "deputes": 5},# ===================== COLLECTION =====================
var collection_decouverte: Dictionary = {}  # {"id": true}
var collection_progression: Dictionary = {}  # {"categorie": total}

const COLLECTION_CATS = [
	{"id": "fleurs", "nom": "Flore", "icone": "🌸", "total": 30},
	{"id": "insectes", "nom": "Insectes", "icone": "🦋", "total": 25},
	{"id": "oiseaux", "nom": "Oiseaux", "icone": "🐦", "total": 15},
	{"id": "mammiferes", "nom": "Mammif\u00e8res", "icone": "🐻", "total": 10},
]

# ===================== EVENEMENTS =====================
var evenement_actif = null
var timer_evenement = 0.0
var prochain_evenement = 0.0

const EVENEMENTS = [
	{"id": "pluie", "nom": "🌧 Printemps humide", "desc": "+50% fleurs", "duree": 30.0},
	{"id": "canicule", "nom": "☀ Canicule", "desc": "Fleurs meurent x2", "duree": 25.0},
	{"id": "floraison", "nom": "🌸 Floraison", "desc": "R\u00e9colte x3", "duree": 20.0},
	{"id": "ours_dodo", "nom": "🐻 Ours endormi", "desc": "Pas d'ours", "duree": 60.0},
	{"id": "bio", "nom": "🚜 Agriculteur bio", "desc": "Pas de pesticides", "duree": 30.0},
]

# ===================== SHOP PRESTIGE =====================
var shop_niveaux = {}

# ===================== SANTE =====================
var sante_ruche_max: float = 100.0  
func get_sante_ruche_max() -> float:
	var bonus = shop_niveaux.get("sante_plus", 0) * 10
	bonus += mutations.get("resistante", 0) * 5
	bonus += ouvriere_specs.get("architecte", 0) * 20
	# Chaque pesticide interdit donne +5% de sante max
	var pesticides_votes = 0
	for pid in PESTICIDE_IDS:
		if lois_votees.has(pid): pesticides_votes += 1
	bonus += pesticides_votes * 5
	return 100.0 + bonus

# ===================== FONCTIONS =====================
func _ready():
	load_save()
	randomize()
	_prochain_evenement()

func _process(delta):
	if evenement_actif:
		timer_evenement -= delta
		if timer_evenement <= 0:
			evenement_actif = null
			evenement.emit("", 0)

func _set_honey(v):
	var old = honey
	honey = max(0, v)
	if honey > old:
		var gain = honey - old
		stats.miel_produit += gain
		var old_t = honey_this_run / 1000
		honey_this_run += gain
		var new_t = honey_this_run / 1000
		if new_t > old_t:
			var d = new_t - old_t
			pollen += d
			stats.pollen_total += d
		# Vérifier déblocage biome
		_verifier_biome()
	honey_change.emit(honey)

func _set_pollen(v):
	pollen = max(0, v)
	pollen_change.emit(pollen)

func get_multiplicateur_recolte() -> float:
	var m = 1.0
	if mutations.has("riche"): m += mutations.get("riche", 0) * 0.2
	if evenement_actif and evenement_actif.id == "floraison": m *= 3.0
	if POWERS_ENABLED and queen_skills.essaim.timer > 0: m *= 3.0
	if evenement_actif and evenement_actif.id == "pluie": m *= 1.5
	return m

func get_vitesse_ouvriere_mult() -> float:
	var base = get_vitesse_ouvriere()
	var m = base
	if mutations.has("rapide"): m -= mutations.get("rapide", 0) * 0.03 * base
	if POWERS_ENABLED and queen_skills.cri_royal.timer > 0: m *= 0.5
	return max(0.1, m)

func get_pesticide_mult() -> float:
	var m = 1.0
	if mutations.has("resistante"): m -= mutations.get("resistante", 0) * 0.03
	if ouvriere_specs.get("infirmiere", 0) > 0: m -= 0.1 * ouvriere_specs.get("infirmiere", 0)
	# Chaque pesticide interdit reduit les pesticides de 5%
	for pid in PESTICIDE_IDS:
		if lois_votees.has(pid): m -= 0.05
	if evenement_actif and evenement_actif.id == "bio": m = 0
	return max(0.2, m)

func get_vie_ruche_max() -> float:
	return get_sante_ruche_max()

# ===================== REINE SKILLS =====================
func utiliser_skill(skill_id: String) -> bool:
	if not queen_skills.has(skill_id): return false
	var sk = queen_skills[skill_id]
	if sk.timer > 0: return false
	sk.timer = sk.cooldown
	return true

func _process_skills(delta):
	for sid in queen_skills:
		if queen_skills[sid].timer > 0:
			queen_skills[sid].timer -= delta
			if queen_skills[sid].timer < 0: queen_skills[sid].timer = 0

# ===================== EVENEMENTS =====================
func _prochain_evenement():
	prochain_evenement = 120.0 + randf() * 180.0  # 2-5 min

func _process_evenements(delta):
	if evenement_actif: return
	prochain_evenement -= delta
	if prochain_evenement <= 0:
		var e = EVENEMENTS[randi() % EVENEMENTS.size()]
		evenement_actif = e
		timer_evenement = e.duree
		evenement.emit(e.nom, e.duree)
		_prochain_evenement()

# ===================== BIOMES =====================
func _verifier_biome():
	var total = stats.miel_produit
	for i in range(BIOMES.size()):
		if total >= BIOMES[i].honey_requis and i > biome_actuel:
			biome_actuel = i
			biome_change.emit(biome_actuel)

# ===================== OUVRIERES =====================
func acheter_ouvriere() -> bool:
	var max_atteignable = MAX_OUVRIERES_BASE + shop_niveaux.get("ouvriere_slots", 0)
	if lois_votees.has("haies"): max_atteignable += 1
	if ouvrieres >= max_atteignable or ouvrieres >= MAX_OUVRIERES_TOTAL: return false
	if honey < COUT_OUVRIERE: return false
	honey -= COUT_OUVRIERE
	ouvrieres += 1
	return true

func acheter_vitesse_click() -> bool:
	var c = get_cout_vitesse_click()
	if niveau_vitesse_click >= 5 or honey < c: return false
	honey -= c; niveau_vitesse_click += 1; return true

func acheter_guerriere() -> bool:
	var niv = shop_niveaux.get("guerriere_slots", 0)
	if niv >= 4: return false
	var c = COUT_GUERRIERE * int(pow(2, niv))
	if honey < c: return false
	honey -= c; niv += 1
	shop_niveaux["guerriere_slots"] = niv
	save(); return true

func acheter_vitesse_ouvriere() -> bool:
	if ouvrieres <= 0: return false
	var c = get_cout_vitesse_ouvriere()
	if niveau_vitesse_ouvriere >= 5 or honey < c: return false
	honey -= c; niveau_vitesse_ouvriere += 1; return true

func acheter_capacite_ouvriere() -> bool:
	if ouvrieres <= 0: return false
	var c = get_cout_capacite_ouvriere()
	if niveau_capacite_ouvriere >= 5 or honey < c: return false
	honey -= c; niveau_capacite_ouvriere += 1; return true

func get_capacite_ouvriere() -> int:
	var base = 1 + shop_niveaux.get("boost_capacite", 0)
	if ouvriere_specs.get("butineuse", 0) > 0: base *= 2
	return base

# ===================== PRESTIGE =====================
func restart():
	var miel_dep = shop_niveaux.get("miel_depart", 0) * 50
	var ouv_dep = shop_niveaux.get("ouvriere_depart", 0)
	# Reset tous les etats temporaires de partie
	niveau_clic = 0; niveau_vitesse_ouvriere = 0; niveau_capacite_ouvriere = 0; niveau_vitesse_click = 0
	lois_votees = {}; guerrieres_actives = 0; evenement_actif = null
	ouvriere_specs = {}; deputes = 0; biome_actuel = 0
	prochain_evenement = 120.0 + randf() * 180.0
	# Reset skills cooldowns
	for sid in queen_skills: queen_skills[sid].timer = 0
	stats.parties += 1
	if honey_this_run > stats.best_run:
		stats.best_run = honey_this_run
	honey = miel_dep; honey_this_run = 0; ouvrieres = max(0, ouv_dep)
	generation += 1
	save()

func acheter_shop(article_id: String) -> bool:
	var niv = shop_niveaux.get(article_id, 0)
	var prix = 0; var max_niv = 0
	match article_id:
		"boost_clic": prix = 2; max_niv = 10
		"boost_capacite": prix = 2; max_niv = 10
		"ouvriere_depart": prix = 3; max_niv = 10
		"miel_depart": prix = 1; max_niv = 20
		"sante_plus": prix = 5; max_niv = 5
		"ouvriere_slots": prix = 1 * int(pow(2, niv)); max_niv = 10
		"recompense_frelon": prix = 2; max_niv = 10
		"recompense_ours": prix = 3; max_niv = 10
		"guerriere_slots": prix = 5; max_niv = 4
		_: return false
	if niv >= max_niv or pollen < prix: return false
	pollen -= prix
	shop_niveaux[article_id] = niv + 1
	save(); return true

# ===================== SAUVEGARDE =====================
func save():
	var file = FileAccess.open(_save_path(), FileAccess.WRITE)
	if not file: return
	file.store_var({
		"victoire": stats.get("victoire", false),
"honey": honey, "pollen": pollen,
		"honey_this_run": honey_this_run,
		"niveau_clic": niveau_clic,
		"niveau_vitesse_ouvriere": niveau_vitesse_ouvriere,
		"niveau_capacite_ouvriere": niveau_capacite_ouvriere,
		"niveau_vitesse_click": niveau_vitesse_click,
		"guerriere_max": shop_niveaux.get("guerriere_slots", 0) + 1,
		"niveau_reine": niveau_reine, "generation": generation,
	"langue": langue,
		"mutations": mutations, "biome_actuel": biome_actuel,
		"ouvrieres": ouvrieres, "ouvriere_specs": ouvriere_specs,
		"deputes": deputes, "lois_votees": lois_votees,
		"shop_niveaux": shop_niveaux,
		"stats": stats, "collection_decouverte": collection_decouverte,
	})
	file.close()

func load_save():
	var file = FileAccess.open(_save_path(), FileAccess.READ)
	if not file: return
	var d = file.get_var()
	if not d: return
	honey = d.get("honey", 0)
	pollen = d.get("pollen", 0)
	honey_this_run = d.get("honey_this_run", 0)
	niveau_clic = d.get("niveau_clic", 0)
	niveau_vitesse_ouvriere = d.get("niveau_vitesse_ouvriere", 0)
	niveau_capacite_ouvriere = d.get("niveau_capacite_ouvriere", 0)
	niveau_vitesse_click = d.get("niveau_vitesse_click", 0)
	niveau_reine = d.get("niveau_reine", 1)
	generation = d.get("generation", 1)
	mutations = d.get("mutations", {})
	biome_actuel = d.get("biome_actuel", 0)
	langue = d.get("langue", "fr")
	ouvrieres = d.get("ouvrieres", 0)
	ouvriere_specs = d.get("ouvriere_specs", {})
	deputes = d.get("deputes", 0)
	lois_votees = d.get("lois_votees", {})
	shop_niveaux = d.get("shop_niveaux", {})
	stats = d.get("stats", {})
	collection_decouverte = d.get("collection_decouverte", {})
	# Migration per-key: completer chaque cle manquante
	if typeof(stats) != TYPE_DICTIONARY: stats = {}
	for k in STATS_DEFAULTS:
		if not stats.has(k): stats[k] = STATS_DEFAULTS[k]
