extends PanelContainer

var hat_id = ""
var hat_price = 0

@onready var preview = $HBoxContainer/TextureRect
@onready var name_label = $HBoxContainer/VBoxContainer/Name
@onready var price_label = $HBoxContainer/VBoxContainer/Price
@onready var action_button = $HBoxContainer/VBoxContainer/action

func setup(id, data):
	hat_id = id
	hat_price = data.price
	preview.texture = load(data.texture)
	name_label.text = data.name
	price_label.text = str(data.price) + " coins"
	refresh()

func refresh():
	var owned = PlayerStats.owned_hats.has(hat_id)
	var equipped = PlayerStats.equipped_hat == hat_id
	
	if not owned:
		action_button.text = "Buy"
		action_button.disabled = PlayerStats.coins < hat_price
	elif equipped:
		action_button.text = "Unequip"
		action_button.disabled = false
	else:
		action_button.text = "Equip"
		action_button.disabled = false

func _on_action_pressed():
	print("Action pressed! Owned: ", PlayerStats.owned_hats.has(hat_id), " Equipped: ", PlayerStats.equipped_hat == hat_id)
	var owned = PlayerStats.owned_hats.has(hat_id)
	var equipped = PlayerStats.equipped_hat == hat_id
	
	if not owned:
		if PlayerStats.buy_hat(hat_id, hat_price):
			refresh()
		else:
			print("Not enough coins!")
	elif equipped:
		PlayerStats.equip_hat("")  
		refresh_all()
	else:
		PlayerStats.equip_hat(hat_id)
		refresh_all()

func refresh_all():
	for panel in get_parent().get_children():
		panel.refresh()
