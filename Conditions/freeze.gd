extends Node

var ticks_remaining = 3
var tick_timer = 0.0
const TICK_TIME = 1.0

var original_speed
var original_velocity

func _ready():
	original_speed = get_parent().speed
	original_velocity = get_parent().velocity
	get_parent().speed = 0
	get_parent().velocity = Vector2.ZERO

func _process(delta):
	tick_timer += delta
	if tick_timer >= TICK_TIME:
		tick_timer = 0.0
		ticks_remaining -= 1
		print("Freeze ticks remaining: ", ticks_remaining)
		if ticks_remaining <= 0:
			var parent = get_parent()
			parent.speed = original_speed
			parent.velocity = original_velocity
			print(parent.name, " is no longer frozen!")
			queue_free()
