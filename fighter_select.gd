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

@onready var fighter_one_select = $"Fighters/Fighter 1/OptionButton"
@onready var fighter_two_select = $"Fighters/Fighter 2/OptionButton"
@onready var bet_on_select = $Betting/BetOn/OptionButton
@onready var bet_spinbox = $Betting/BetAmount/SpinBox
@onready var same_fighter_popup = $SameFighterPopup


func _ready():
	bet_spinbox.max_value = PlayerStats.coins
	for fighter in FIGHTERS.keys():
		fighter_one_select.add_item(fighter)
		fighter_two_select.add_item(fighter)
	
func _process(delta):
	bet_spinbox.max_value = PlayerStats.coins

func _on_fight_pressed():
	if fighter_one_select.selected == fighter_two_select.selected:
		same_fighter_popup.popup_centered()
		return
	
	GameState.fighter_one = FIGHTERS[fighter_one_select.get_item_text(fighter_one_select.selected)]
	GameState.fighter_two = FIGHTERS[fighter_two_select.get_item_text(fighter_two_select.selected)]
	GameState.bet_amount = int(bet_spinbox.value)
	GameState.bet_on = "one" if bet_on_select.selected == 0 else "two"
	get_tree().change_scene_to_file("res://game.tscn")

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://shop.tscn")


func _on_all_in_pressed() -> void:
	bet_spinbox.value = PlayerStats.coins
	GameState.bet_amount = int(bet_spinbox.value)
