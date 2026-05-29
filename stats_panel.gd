extends VBoxContainer

var team = ""
var last_count = 0

@onready var card_list = $ScrollContainer/CardList
const ORB_CARD = preload("res://orb_card.tscn")

func setup(orb_team):
	team = orb_team

func _process(delta):
	var alive = get_tree().get_nodes_in_group("ball").filter(func(b): return b.team == team)
		

	if alive.size() != last_count:
		last_count = alive.size()
		for child in card_list.get_children():
			child.queue_free()
		for orb in alive:
			var card = ORB_CARD.instantiate()
			card_list.add_child(card)
	
	for i in card_list.get_child_count():
		if i >= alive.size():
			break
		var card = card_list.get_child(i)
		var orb = alive[i]
		card.get_node("VBoxContainer/Name").text = orb.name
		card.get_node("VBoxContainer/Health").text = "HP: " + str(orb.health)
		card.get_node("VBoxContainer/Damage").text = "DMG: " + str(orb.damage)
		card.get_node("VBoxContainer/Speed").text = "SPD: " + str(orb.speed)
		card.get_node("VBoxContainer/FighterPrev").texture = orb.get_node("Sprite2D").texture
