extends Area2D

var rotation_speed = 3.0  # radians per second
var weapon_damage = 15
var on_cooldown = false

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	get_parent().rotation += rotation_speed * delta  # spin the pivot

func _on_body_entered(body):
	if on_cooldown:
		return
	if not body.is_in_group("ball"):
		return
	if body == get_parent().get_parent():
		return  # check for hitting itself
	
	body.take_damage(weapon_damage, body.name)
	
	# push the hit enemy away from the weapon's position
	var push_direction = body.global_position - global_position
	body.velocity = push_direction.normalized() * body.speed
	
	# cooldown 
	on_cooldown = true
	get_tree().create_timer(0.5).timeout.connect(func(): on_cooldown = false)
	
