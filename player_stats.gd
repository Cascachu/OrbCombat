extends Node

const SAVE_PATH = "user://stats.txt"

var coins = 100
var wins = 0
var losses = 0
var owned_hats = []
var equipped_hat = ""

func _ready():
	load_stats()

func save_stats():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(str(coins))
	file.store_line(str(wins))
	file.store_line(str(losses))
	file.store_line(",".join(owned_hats))
	file.store_line(equipped_hat)
	file.close()

func load_stats():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	coins = int(file.get_line())
	wins = int(file.get_line())
	losses = int(file.get_line())
	var hats_line = file.get_line()
	owned_hats = [] if hats_line == "" else hats_line.split(",")
	equipped_hat = file.get_line()
	file.close()
	
func add_win(bet):
	wins += 1
	coins += bet * 2
	save_stats()

func add_loss(bet):
	losses += 1
	coins -= bet
	save_stats()

func add_draw(bet):
	coins += bet 
	save_stats()
	
func buy_hat(hat_id, price):
	if coins >= price and not owned_hats.has(hat_id):
		coins -= price
		owned_hats.append(hat_id)
		save_stats()
		return true
	return false

func equip_hat(hat_id):
	equipped_hat = hat_id
	save_stats()
