extends Panel

func _ready():
	hide()

func show_result(result):
	$VBoxContainer/Result.text = result
	show()

func _on_play_again_pressed():
	get_tree().change_scene_to_file("res://fighter_select.tscn")
