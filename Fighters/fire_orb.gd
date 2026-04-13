extends "res://Fighters/ball.gd"

func _ready():
	max_health = 80
	damage = 0
	size = 0.8
	super._ready()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ball"):
			apply_burn(collider)
			take_damage(collider.damage, name)
			var push_direction = global_position - collider.global_position
			velocity = push_direction.normalized() * speed
		else:
			velocity = velocity.bounce(collision.get_normal())

func apply_burn(target):
	var existing = target.get_node_or_null("Burn")
	if existing:
		existing.stacks += 1
		return
	
	var burn = Node.new()
	burn.name = "Burn"
	burn.set_script(preload("res://Abilities/burn.gd"))
	target.add_child(burn)
	burn.stacks = 1
