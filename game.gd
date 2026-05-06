extends Node2D
var fighter_one
var fighter_two
func _ready():
	fighter_one = load(GameState.fighter_one).instantiate()
	fighter_two = load(GameState.fighter_two).instantiate()
	
	fighter_one.position = Vector2(200, 300)
	fighter_two.position = Vector2(600, 300)
	
	$Fighters.add_child(fighter_one)
	$Fighters.add_child(fighter_two)
	
	$CanvasLayer/LeftPanel.setup(fighter_one)
	$CanvasLayer/RightPanel.setup(fighter_two)

func _process(delta):
	var one_alive = is_instance_valid(fighter_one)
	var two_alive = is_instance_valid(fighter_two)
	
	if !one_alive and !two_alive:
		show_game_over("Draw!")
	elif !one_alive:
		show_game_over(fighter_two.name + " wins!")
	elif !two_alive:
		show_game_over(fighter_one.name + " wins!")

func show_game_over(result):
	set_process(false)  # stop checking
	$CanvasLayer/game_over_panel.show_result(result)
