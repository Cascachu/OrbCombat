extends Node2D

func _ready():
	var fighter_one = load(GameState.fighter_one).instantiate()
	var fighter_two = load(GameState.fighter_two).instantiate()
	
	fighter_one.position = Vector2(200, 300)
	fighter_two.position = Vector2(600, 300)
	
	$Fighters.add_child(fighter_one)
	$Fighters.add_child(fighter_two)
	
	$CanvasLayer/LeftPanel.setup(fighter_one)
	$CanvasLayer/RightPanel.setup(fighter_two)
