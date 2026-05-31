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
		var all_suffixes = {
			"": ["II", "III"],
			"II": ["IV", "V"],
			"III": ["VI", "VII"],
		}
		var parts = name.split(" ")
		var current_suffix = "" if parts.size() == 1 else parts[-1]
		var base_name = parts[0]
		var children_suffixes = all_suffixes.get(current_suffix, ["II", "III"])
		
		for i in 2:
			var child = duplicate()
			child.generation = generation + 1
			child.team = team
			child.skip_name_fetch = true
			child.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			child.name = base_name + " " + children_suffixes[i]
			get_parent().add_child(child)
			child.call_deferred("_ready")
			var freeze = child.get_node_or_null("Freeze")
			if freeze:
				freeze.queue_free()
	queue_free()
