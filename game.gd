extends Node2D
var fighter_one
var fighter_two
var fighter_one_name = ""
var fighter_two_name = ""
func _ready():
	fighter_one = load(GameState.fighter_one).instantiate()
	fighter_two = load(GameState.fighter_two).instantiate()
	fighter_one_name = fighter_one.name
	fighter_two_name = fighter_two.name
	fighter_one.team = "one"
	fighter_two.team = "two"
	fighter_one.position = Vector2(200, 300)
	fighter_two.position = Vector2(600, 300)
	$Fighters.add_child(fighter_one)
	$Fighters.add_child(fighter_two)
	
	$CanvasLayer/LeftPanel.setup(fighter_one)
	$CanvasLayer/RightPanel.setup(fighter_two)

func _process(delta):
	var one_alive = get_tree().get_nodes_in_group("ball").any(func(b): return b.team == "one")
	var two_alive = get_tree().get_nodes_in_group("ball").any(func(b): return b.team == "two")
	
	if !one_alive and !two_alive:
		show_game_over("Draw!")
	elif !one_alive:
		show_game_over(fighter_two_name + " wins!")
	elif !two_alive:
		show_game_over(fighter_one_name + " wins!")

func show_game_over(result):
	set_process(false)  # stop checking
	$CanvasLayer/game_over_panel.show_result(result)
