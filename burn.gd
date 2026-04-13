extends Node

var stacks = 1
var timer = 0.0
const BURN_TICK = 1.0

func _process(delta):
	timer += delta
	if timer >= BURN_TICK:
		timer = 0.0
		var parent = get_parent()
		parent.health -= stacks
		print("Burned for ", stacks, "! Health: ", parent.health)
		if parent.health <= 0:
			parent.queue_free()
