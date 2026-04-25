extends Panel

var tracked_orb = null

@onready var name_label = $Name
@onready var health_label = $Health
@onready var damage_label = $Damage
@onready var speed_label = $Speed
@onready var fighter_prev = $FighterPrev

func setup(orb):
	tracked_orb = orb
	fighter_prev.texture = orb.get_node("Sprite2D").texture
	
func _process(delta):
	if not tracked_orb or not is_instance_valid(tracked_orb):
		name_label.text = "Dead"
		health_label.text = ""
		damage_label.text = ""
		speed_label.text = ""
		return
	
	name_label.text = tracked_orb.name
	health_label.text = "Health: " + str(tracked_orb.health)
	damage_label.text = "Damage: " + str(tracked_orb.damage)
	speed_label.text = "Speed: " + str(tracked_orb.speed)
