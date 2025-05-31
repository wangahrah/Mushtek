extends Node

# Dictionary to store items and their quantities
var inventory: Dictionary = {}

# Signal to notify when inventory changes
signal inventory_changed(item_name: String, quantity: int)

func add_item(item_name: String, quantity: int) -> void:
	if inventory.has(item_name):
		inventory[item_name] += quantity
	else:
		inventory[item_name] = quantity
	emit_signal("inventory_changed", item_name, inventory[item_name])

func remove_item(item_name: String, quantity: int) -> bool:
	if inventory.has(item_name) and inventory[item_name] >= quantity:
		inventory[item_name] -= quantity
		if inventory[item_name] <= 0:
			inventory.erase(item_name)
		emit_signal("inventory_changed", item_name, inventory.get(item_name, 0))
		return true
	return false

func get_item_quantity(item_name: String) -> int:
	return inventory.get(item_name, 0)

func has_item(item_name: String) -> bool:
	return inventory.has(item_name) 
