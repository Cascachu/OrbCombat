extends Panel

@onready var coins_label = $HBoxContainer/Coins
@onready var wins_label = $HBoxContainer/Wins
@onready var losses_label = $HBoxContainer/Losses

func _process(delta):
	coins_label.text = "Coins: " + str(PlayerStats.coins)
	wins_label.text = "Wins: " + str(PlayerStats.wins)
	losses_label.text = "Losses: " + str(PlayerStats.losses)
