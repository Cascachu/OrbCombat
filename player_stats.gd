extends Node

const DB_PATH = "user://orbcombat.db"
var db

func _ready():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	_create_tables()
	load_stats()

func _create_tables():
	db.query("""
        CREATE TABLE IF NOT EXISTS stats (
            id INTEGER PRIMARY KEY,
            coins INTEGER DEFAULT 100,
            wins INTEGER DEFAULT 0,
            losses INTEGER DEFAULT 0,
            equipped_hat TEXT DEFAULT ''
        )
	""")
	db.query("""
        CREATE TABLE IF NOT EXISTS owned_hats (
            hat_id TEXT PRIMARY KEY
        )
	""")
	db.query("SELECT COUNT(*) as count FROM stats")
	if db.query_result[0]["count"] == 0:
		db.query("INSERT INTO stats (id, coins, wins, losses, equipped_hat) VALUES (1, 100, 0, 0, '')")

var coins = 100
var wins = 0
var losses = 0
var owned_hats = []
var equipped_hat = ""

func save_stats():
	db.query("UPDATE stats SET coins = %d, wins = %d, losses = %d, equipped_hat = '%s' WHERE id = 1" % [coins, wins, losses, equipped_hat])
	db.query("DELETE FROM owned_hats")
	for hat_id in owned_hats:
		db.query("INSERT INTO owned_hats (hat_id) VALUES ('%s')" % hat_id)

func load_stats():
	db.query("SELECT * FROM stats WHERE id = 1")
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		coins = row["coins"]
		wins = row["wins"]
		losses = row["losses"]
		equipped_hat = row["equipped_hat"]
	
	db.query("SELECT hat_id FROM owned_hats")
	owned_hats = []
	for row in db.query_result:
		owned_hats.append(row["hat_id"])

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

func reset_stats():
	coins = 100
	wins = 0
	losses = 0
	owned_hats = []
	equipped_hat = ""
	db.query("UPDATE stats SET coins = 100, wins = 0, losses = 0, equipped_hat = '' WHERE id = 1")
	db.query("DELETE FROM owned_hats")
