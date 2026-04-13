extends "res://Fighters/ball.gd"

func _ready():
	max_health = 100
	damage = 5
	size = 1.0
	super._ready()

func use_ability(target):
	pass  # weapon handles its own damage
