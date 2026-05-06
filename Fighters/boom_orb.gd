extends "res://Fighters/ball.gd"

var tick_timer = 0.0
const TICK_TIME = 1.0
var ticks = 0
const TICKS_TO_EXPLODE = 5
const EXPLOSION_DAMAGE = 25
const EXPLOSION_RADIUS = 150.0

var explosion_scene = preload("res://Effects/explosion.tscn")


func _ready():
	max_health = 100
	damage = 5
	size = 1.2
	super._ready()

func use_ability(target):
	pass

func _physics_process(delta):
	tick_timer += delta
	if tick_timer >= TICK_TIME:
		tick_timer = 0.0
		ticks += 1
		print("Boom ball ticks: ", ticks)
		if ticks >= TICKS_TO_EXPLODE:
			ticks = 0
			explode()
	super._physics_process(delta)

func explode():
	print(name, " explodes!")
	var explosion = explosion_scene.instantiate()
	explosion.position = global_position
	explosion.source = self
	get_parent().add_child(explosion)
