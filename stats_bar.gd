extends Panel

func _process(delta):
	if has_node("HBoxContainer/Coins"):
		$HBoxContainer/Coins.text = "Coins: " + str(PlayerStats.coins)
	if has_node("HBoxContainer/Wins"):
		$HBoxContainer/Wins.text = "Wins: " + str(PlayerStats.wins)
	if has_node("HBoxContainer/Losses"):
		$HBoxContainer/Losses.text = "Losses: " + str(PlayerStats.losses)
