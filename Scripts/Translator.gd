extends Node

var _lang: String = "fr"
var _dict: Dictionary = {}

func _ready():
	load_csv("fr")

func load_csv(lang: String):
	_lang = lang
	_dict.clear()
	var f = FileAccess.open("res://Localization/translations.csv", FileAccess.READ)
	if not f: return
	var header = f.get_csv_line()  # keys,fr,en
	var col = 1 if lang == "fr" else 2 if lang == "en" else 1
	while not f.eof_reached():
		var row = f.get_csv_line()
		if row.size() >= 3 and row[0] != "":
			_dict[row[0]] = row[col]
	f.close()

func t(key: String) -> String:
	return _dict.get(key, key)

func get_lang() -> String:
	return _lang

func set_lang(lang: String):
	load_csv(lang)
