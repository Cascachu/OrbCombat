extends "res://Fighters/ball.gd"

var generation = 0
const MAX_GENERATIONS = 2

func _ready():
	match generation:
		0: #big
			max_health = 100
			damage = 8
			size = 1.2
		1: #medium
			max_health = 50
			damage = 4
			size = 1.0
		2: #small
			max_health = 25
			damage = 2
			size = 0.6
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
		for i in 2:
			var child = duplicate()
			child.generation = generation + 1
			child.position = position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
			get_parent().add_child(child)
			child._ready()
			child.name = "SlimeOrb_Gen" + str(generation + 1) + "_" + str(i+1) #each child slime orb has its own name for clarity
	queue_free()
