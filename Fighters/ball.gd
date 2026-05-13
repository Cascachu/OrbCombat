extends CharacterBody2D

var team = ""
var speed = 600
var max_health = 100
var damage = 10
var size = 1.0
var health

var invincible = false
var invincibility_timer = 0.0
const INVINCIBILITY_TIME = 0.3

var deathParticle = preload("res://Effects/death_particle.tscn")
static var handled_this_frame = []

func _ready():
	add_to_group("ball")
	health = max_health
	velocity = Vector2(-200, -200).normalized() * speed
	scale = Vector2(size, size)

func take_damage(amount, damaged_name):
	health -= amount
	print(damaged_name, " got hit! Health: ", health)
	if health <= 0:
		death()

func use_ability(target):
	pass  # base ball has no ability, child classes override this

func _physics_process(delta):
	handled_this_frame.clear()
	
	if invincible:
		invincibility_timer += delta
		if invincibility_timer >= INVINCIBILITY_TIME:
			invincible = false

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ball"):
			var collision_id = [min(get_instance_id(), collider.get_instance_id()), max(get_instance_id(), collider.get_instance_id())]
			if not handled_this_frame.has(collision_id):
				handled_this_frame.append(collision_id)
				if !invincible and !collider.invincible:
					if not collider.get_node_or_null("Freeze"):  # frozen orbs dont deal damage
						take_damage(collider.damage, name)
					collider.take_damage(damage, collider.name)
					use_ability(collider)
					collider.use_ability(self)
					invincible = true
					invincibility_timer = 0.0
					collider.invincible = true
					collider.invincibility_timer = 0.0
			var push_direction = global_position - collider.global_position
			var random_angle = randf_range(-0.6, 0.6)
			velocity = push_direction.normalized().rotated(random_angle) * speed
		else:
			velocity = velocity.bounce(collision.get_normal()).rotated(randf_range(-0.4, 0.4))
func death():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	queue_free()
