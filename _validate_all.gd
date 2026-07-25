#!/usr/bin/env godot --headless --script
# Validate all project scripts by loading each scene
extends SceneTree

func _init():
	print("=== Validation de tous les scripts ===")
	
	var paths = [
		"res://Scenes/Assemblee/AssembleeScreen.tscn",
		"res://Scenes/Assemblee/AssembleeScreen.gd",
		"res://Scenes/Main/Main.tscn",
		"res://Scenes/Main/Main.gd",
		"res://Scenes/Menu/Menu.gd",
		"res://Scenes/GameOver/GameOverScreen.gd",
		"res://Scripts/GameManager.gd",
		"res://Tests.gd",
	]
	
	var errors = []
	for path in paths:
		print("Validation: ", path)
		var res = load(path)
		if res == null:
			errors.append("Impossible de charger: " + path)
		else:
			print("  OK: ", path)
	
	if errors.size() == 0:
		print("=== TOUS LES SCRIPTS VALIDES ===")
	else:
		print("=== ERREURS: ", str(errors.size()), " ===")
		for e in errors:
			print("  X ", e)
	
	quit(errors.size())
