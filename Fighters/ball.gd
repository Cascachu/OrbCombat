extends CharacterBody2D

var speed = 300.0
var max_health = 100
var damage = 10
var size = 1.0
var health



func _ready():
	health = max_health
	velocity = Vector2(-200, -200).normalized()*speed
	scale = Vector2(size, size)

func take_damage(amount, name):
	health -= amount
	print(name, " got hit! Health: ", health)
	if health <= 0:
		queue_free()


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.is_in_group("ball"):
			take_damage(collider.damage, name)
			var push_direction = global_position - collider.global_position
			velocity = push_direction.normalized() * speed
