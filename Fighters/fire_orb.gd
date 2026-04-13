extends "res://Fighters/ball.gd"

func _ready():
	max_health = 100
	damage = 0
	size = 0.9
	super._ready()

func use_ability(target):
	var existing = target.get_node_or_null("Burn")
	if existing:
		existing.stacks += 1
		return
	var burn = Node.new()
	burn.name = "Burn"
	burn.set_script(preload("res://Conditions/burn.gd"))
	target.add_child(burn)
	burn.stacks = 1
