extends Control

const FIGHTERS = {
	"Ball": "res://Fighters/ball.tscn",
	"Fire Orb": "res://Fighters/fire_orb.tscn",
	"Ice Orb": "res://Fighters/ice_orb.tscn",
	"Slime Orb": "res://Fighters/slime_orb.tscn",
	"Sword Orb": "res://Fighters/sword_orb.tscn",
	"Boom Orb": "res://Fighters/boom_orb.tscn",
	"Puffer Orb": "res://Fighters/puffer_orb.tscn",
}

@onready var fighter_one_select = $"Fighter 1/OptionButton"
@onready var fighter_two_select = $"Fighter 2/OptionButton"

func _ready():
	for fighter in FIGHTERS.keys():
		fighter_one_select.add_item(fighter)
		fighter_two_select.add_item(fighter)

func _on_fight_pressed():
	GameState.fighter_one = FIGHTERS[fighter_one_select.get_item_text(fighter_one_select.selected)]
	GameState.fighter_two = FIGHTERS[fighter_two_select.get_item_text(fighter_two_select.selected)]
	get_tree().change_scene_to_file("res://game.tscn")
