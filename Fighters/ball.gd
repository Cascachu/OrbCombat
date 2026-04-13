extends CharacterBody2D

var speed = 600.0
var max_health = 100
var damage = 10
var size = 1.0
var health

var invincible = false
var invincibility_timer = 0.0
const INVINCIBILITY_TIME = 0.3

func _ready():
	add_to_group("ball")
	health = max_health
	velocity = Vector2(-200, -200).normalized() * speed
	scale = Vector2(size, size)

func take_damage(amount, damaged_name):
	health -= amount
	print(damaged_name, " got hit! Health: ", health)
	if health <= 0:
		queue_free()

func use_ability(target):
	pass  # base ball has no ability, child classes override this

func _physics_process(delta):
	if invincible:
		invincibility_timer += delta
		if invincibility_timer >= INVINCIBILITY_TIME:
			invincible = false
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ball"):
			if !invincible:
				use_ability(collider)  
				take_damage(collider.damage, name)
			var push_direction = global_position - collider.global_position
			var random_angle = randf_range(-0.6, 0.6)
			velocity = push_direction.normalized().rotated(random_angle) * speed
			invincible = true
			invincibility_timer = 0.0
			
		else:
			velocity = velocity.bounce(collision.get_normal()).rotated(randf_range(-0.4, 0.4))
