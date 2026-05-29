extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://fighter_select.tscn")


func _on_reset_pressed() -> void:
	$ConfirmationDialog.popup_centered()


func _on_confirmation_dialog_confirmed() -> void:
	PlayerStats.reset_stats()
