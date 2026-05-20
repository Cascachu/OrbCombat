extends Control

@onready var hat_list = $ScrollContainer/hat_list

const HAT_PANEL = preload("res://hat_panel.tscn")

func _ready():
	print("Hat list child count: ", hat_list.get_child_count())
	for hat_id in Hats.HATS:
		var panel = HAT_PANEL.instantiate()
		hat_list.add_child(panel)
		panel.setup(hat_id, Hats.HATS[hat_id])
		print("Added panel, child count now: ", hat_list.get_child_count())

func _on_back_pressed():
	get_tree().change_scene_to_file("res://fighter_select.tscn")
