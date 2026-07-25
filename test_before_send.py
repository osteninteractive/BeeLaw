#!/usr/bin/env python3
"""BeeLaw - Test complet avant envoi"""
import subprocess, os, re, sys, shutil
from pathlib import Path

ROOT = str(Path(__file__).resolve().parent)
errors = []
warnings = []

def e(msg): errors.append(msg)
def w(msg): warnings.append(msg)

# 0. Godot present?
godot_path = shutil.which("godot") or shutil.which("godot4")
if godot_path is None:
    e("Godot introuvable")
else:
    print("0. Godot: " + godot_path)

# 1. Fichiers essentiels
print("1. Fichiers essentiels...")
essentials = ['project.godot', 'Scenes/Main/Main.gd', 'Scripts/GameManager.gd',
              'Scenes/Menu/Menu.gd', 'Scenes/GameOver/GameOverScreen.gd',
              'Scenes/Assemblee/AssembleeScreen.gd',
              'Scripts/BeeManager.gd', 'Scripts/FlowerManager.gd',
              'Scripts/ThreatManager.gd', 'Scripts/prestige_items.gd']
for f in essentials:
    if not os.path.exists(os.path.join(ROOT, f)):
        e("Fichier manquant: " + f)

# 2. Compilation Godot
print("2. Compilation Godot...")
if godot_path:
    r = subprocess.run(
        [godot_path, "--headless", "--editor", "--path", ROOT, "--quit"],
        capture_output=True, text=True, timeout=20
    )
    stderr = r.stderr
    parse_errors = [l for l in stderr.split('\n') if 'Parse error' in l or 'SCRIPT ERROR' in l]
    for err in parse_errors:
        e(err.strip())
    if r.returncode != 0:
        e("Compilation: code de sortie " + str(r.returncode))
    if not parse_errors and r.returncode == 0:
        print("  0 erreur (exit " + str(r.returncode) + ")")
else:
    e("Compilation non executee (Godot absent)")

# 3. Tests Godot
print("3. Tests Godot...")
if godot_path:
    r = subprocess.run(
        [godot_path, "--headless", "--path", ROOT, "Tests.tscn"],
        capture_output=True, text=True, timeout=25
    )
    output = r.stdout + r.stderr
    if r.returncode != 0:
        e("Tests: code de sortie " + str(r.returncode))
    if "0 echecs" in output or "0 failures" in output:
        print("  0 echec (exit " + str(r.returncode) + ")")
    else:
        for l in output.split('\n'):
            if 'FAIL' in l or 'echec' in l:
                e(l.strip())
else:
    e("Tests non executes (Godot absent)")

# 4. Variables dupliquees
print("4. Variables dupliquees...")
with open(os.path.join(ROOT, 'Scenes/Main/Main.gd')) as f:
    main_content = f.read()
vars_main = re.findall(r'^var (\w+)', main_content, re.MULTILINE)
seen = set()
for v in vars_main:
    if v in seen:
        e("Variable dupliquee: " + v)
    seen.add(v)

# 5. Fonctions GameManager referencees
print("5. Fonctions GameManager...")
with open(os.path.join(ROOT, 'Scripts/GameManager.gd')) as f:
    gm_content = f.read()
gm_funcs = set(re.findall(r'func (\w+)', gm_content))
gm_signals = set(re.findall(r'^signal (\w+)', gm_content, re.MULTILINE))
gm_vars = set(re.findall(r'^var (\w+)', gm_content, re.MULTILINE))
gm_consts = set(re.findall(r'^const (\w+)', gm_content, re.MULTILINE))
refs = set(re.findall(r'GameManager\.(\w+)', main_content))
whitelist = {'honey','dollars','honey_this_run','ouvrieres','deputes',
    'niveau_clic','niveau_vitesse_ouvriere','niveau_capacite_ouvriere',
    'niveau_vitesse_click','niveau_guerriere','niveau_max_butineuse',
    'biome_actuel','generation','niveau_reine',
    'stats','queen_skills','shop_niveaux','mutations','ouvriere_specs',
    'lois_votees','evenement_actif','collection_decouverte','FLEURS_DATA',
    'MAX_OUVRIERES_BASE','MAX_OUVRIERES_TOTAL','COUT_OUVRIERE',
    'COUT_GUERRIERE','COUT_DEPUTE','PESTICIDE_IDS',
    'BIOMES','COLLECTION_CATS','EVENEMENTS',
    'LOIS','MUTATIONS_DISPONIBLES','SPECIALISATIONS','sante_ruche_max',
    'langue','guerrieres_actives','save_path','set_save_path','STATS_DEFAULTS','victoire'}
for ref in sorted(refs):
    if ref.startswith('_') or ref in gm_vars or ref in gm_signals or ref in gm_funcs or ref in gm_consts:
        continue
    if ref in whitelist:
        continue
    e("GameManager." + ref + " non trouve")

# RESULTATS
print("")
print("=" * 50)
print("RESULTATS: " + str(len(errors)) + " erreurs")
for err in errors:
    print("  X " + err)
sys.exit(1 if errors else 0)
