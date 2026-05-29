extends Node2D

@onready var left_border = $left
@onready var right_border = $right
@onready var top_border = $top
@onready var bottom_border = $bottom

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var thickness = 50.0
	
	left_border.global_position = Vector2(-thickness / 2, screen_size.y / 2)
	left_border.get_node("CollisionShape2D").shape.size = Vector2(thickness, screen_size.y)
	
	right_border.global_position = Vector2(screen_size.x + thickness / 2, screen_size.y / 2)
	right_border.get_node("CollisionShape2D").shape.size = Vector2(thickness, screen_size.y)
	
	top_border.global_position = Vector2(screen_size.x / 2, -thickness / 2)
	top_border.get_node("CollisionShape2D").shape.size = Vector2(screen_size.x, thickness)
	
	bottom_border.global_position = Vector2(screen_size.x / 2, screen_size.y + thickness / 2)
	bottom_border.get_node("CollisionShape2D").shape.size = Vector2(screen_size.x, thickness)
