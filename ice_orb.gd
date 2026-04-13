extends "res://Fighters/ball.gd"

func _ready():
	max_health = 90
	damage = 5
	size = 1.2
	super._ready()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("ball"):
			collider.take_damage(damage, collider.name)  # ice orb deals its damage to the frozen ball
			take_damage(collider.damage, name)            # ice orb takes damage from the frozen ball
			apply_freeze(collider)
			var push_direction = global_position - collider.global_position
			velocity = push_direction.normalized() * speed
		else:
			velocity = velocity.bounce(collision.get_normal())

func apply_freeze(target):
	var existing = target.get_node_or_null("Freeze")
	if existing:
		existing.ticks_remaining = 5  
		return
	
	var freeze = Node.new()
	freeze.name = "Freeze"
	freeze.set_script(preload("res://Abilities/freeze.gd"))
	target.add_child(freeze)
