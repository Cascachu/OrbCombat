extends Control

var fighter_one
var fighter_two
var fighter_one_name = ""
var fighter_two_name = ""

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	var arena_size = $WorldBorders.scale * Vector2(854, 480)
	$WorldBorders.position = (screen_size - arena_size) / 2
	
	fighter_one = load(GameState.fighter_one).instantiate()
	fighter_two = load(GameState.fighter_two).instantiate()
	
	fighter_one.team = "one"
	fighter_two.team = "two"
	
	fighter_one.position = Vector2(400, 420)
	fighter_two.position = Vector2(800, 420)
	
	$Fighters.add_child(fighter_one)
	$Fighters.add_child(fighter_two)
	
	# connect to name_loaded signal to store names once api responds
	fighter_one.name_loaded.connect(func(): fighter_one_name = fighter_one.name)
	fighter_two.name_loaded.connect(func(): fighter_two_name = fighter_two.name)
	
	if PlayerStats.equipped_hat != "":
		var hat_data = Hats.HATS[PlayerStats.equipped_hat]
		var bet_fighter = fighter_one if GameState.bet_on == "one" else fighter_two
		bet_fighter.get_node("Hat").texture = load(hat_data.texture)
	
	$CanvasLayer/LeftPanel.setup("one")
	$CanvasLayer/RightPanel.setup("two")

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
	set_process(false) # stop checking
	
	var winning_team = ""
	if result == "Draw!":
		winning_team = "draw"
	else:
		# find which team is still alive
		var alive = get_tree().get_nodes_in_group("ball")
		if alive.size() > 0:
			winning_team = alive[0].team
	
	if winning_team == "draw":
		PlayerStats.add_draw(GameState.bet_amount)
	elif winning_team == GameState.bet_on:
		PlayerStats.add_win(GameState.bet_amount)
	else:
		PlayerStats.add_loss(GameState.bet_amount)
	
	$CanvasLayer/GameOverPanel.show_result(result)
