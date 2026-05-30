extends "res://Fighters/ball.gd"

var generation = 0
const MAX_GENERATIONS = 2

func _ready():
	match generation:
		0: #big
			max_health = 100
			damage = 8
			size = 1.2
			speed = 350
		1: #medium
			max_health = 50
			damage = 4
			size = 1.0
			speed = 500
		2: #small
			max_health = 25
			damage = 2
			size = 0.6
			speed = 650
	super._ready()

func use_ability(target):
	pass

var is_dying = false

func take_damage(amount, damaged_name):
	if is_dying:
		return
	health -= amount
	print(damaged_name, " got hit! Health: ", health)
	if health <= 0:
		die()

func die():
	is_dying = true
	if generation < MAX_GENERATIONS:
		var suffixes = ["II", "III", "IV", "V"]
		var base_name = name.split(" the ")[0]  # get the base name without any suffix
		for i in 2:
			var child = duplicate()
			child.generation = generation + 1
			child.team = team
			child.skip_name_fetch = true  # don't fetch a new name
			child.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			get_parent().add_child(child)
			child.call_deferred("_ready")
			child.name = base_name + " the " + suffixes[generation]
	queue_free()
