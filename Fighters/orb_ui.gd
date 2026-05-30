extends VBoxContainer

@onready var health_bar = $HealthBar

func _ready():
	var parent = get_parent()
	health_bar.max_value = parent.max_health

func _process(delta):
	var parent = get_parent()
	health_bar.value = parent.health
