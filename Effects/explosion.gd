extends Area2D

const EXPLOSION_DAMAGE = 25
const SHRINK_SPEED = 0.5
const MIN_SCALE = 0.5
var source = null

func _ready():
	$Sprite2D.scale = Vector2.ONE
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		if body.is_in_group("ball") and body != source:
			body.take_damage(EXPLOSION_DAMAGE, body.name)
			var push_direction = body.global_position - global_position
			body.velocity = push_direction.normalized() * body.speed

func _process(delta):
	var current_scale = $Sprite2D.scale.x
	if current_scale > MIN_SCALE:
		$Sprite2D.scale -= Vector2(SHRINK_SPEED * delta, SHRINK_SPEED * delta)
		$Sprite2D.modulate.a = (current_scale - MIN_SCALE) / (1.0 - MIN_SCALE)
	else:
		queue_free()
