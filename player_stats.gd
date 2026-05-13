extends Node

const SAVE_PATH = "user://stats.txt"

var coins = 0
var wins = 0
var losses = 0

func _ready():
	load_stats()

func save_stats():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(str(coins))
	file.store_line(str(wins))
	file.store_line(str(losses))
	file.close()

func load_stats():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	coins = int(file.get_line())
	wins = int(file.get_line())
	losses = int(file.get_line())
	file.close()

func add_win():
	wins += 1
	coins += 100
	save_stats()

func add_loss():
	losses += 1
	save_stats()

func add_draw():
	coins += 25
	save_stats()
