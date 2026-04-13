extends "res://Fighters/ball.gd"

func _ready():
	max_health = 100
	damage = 5
	size = 1.1
	super._ready()

func use_ability(target):
	var existing = target.get_node_or_null("Freeze")
	if existing:
		existing.ticks_remaining = 3
		return
	
	var freeze = Node.new()
	freeze.name = "Freeze"
	freeze.set_script(preload("res://Conditions/freeze.gd"))
	target.add_child(freeze)
