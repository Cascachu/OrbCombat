extends "res://Fighters/ball.gd"
@export var normal_texture: Texture2D
@export var puff_texture: Texture2D
var puffed = false
var puff_timer = 0.0
var cooldown_timer = 0.0
const PUFF_DURATION = 5.0
const PUFF_COOLDOWN = 10.0

var normal_size
var normal_damage

func _ready():
	max_health = 100
	damage = 5
	size = 0.6
	super._ready()
	normal_size = size
	normal_damage = damage

func use_ability(target):
	if !puffed and cooldown_timer<=0:
		puff()
	else:
		pass

func _physics_process(delta):
	if puffed:
		puff_timer += delta
		if puff_timer >= PUFF_DURATION:
			depuff()
	elif cooldown_timer > 0:
		cooldown_timer -= delta
	super._physics_process(delta)

func puff():
	puffed = true
	puff_timer = 0.0
	damage = 15
	$Sprite2D.texture = puff_texture
	scale = Vector2(2.0, 2.0)
	print(name, " puffed up!")

func depuff():
	puffed = false
	cooldown_timer = PUFF_COOLDOWN
	damage = normal_damage
	$Sprite2D.texture = normal_texture
	scale = Vector2(normal_size, normal_size)
	print(name, " deflated!")
