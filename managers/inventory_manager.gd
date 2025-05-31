extends Node

# Dictionary to store items and their quantities
var inventory: Dictionary = {}
const MAX_NATOMS: int = 500  # Maximum natoms player can hold per tier

# Signal to notify when inventory changes
signal inventory_changed(item_name: String, quantity: int)

func add_item(item_name: String, quantity: int) -> void:
	if item_name.begins_with("natom_tier_"):
		# For natom items, enforce the maximum limit
		var current_amount = inventory.get(item_name, 0)
		var new_amount = min(current_amount + quantity, MAX_NATOMS)
		var actual_amount = new_amount - current_amount
		
		if actual_amount > 0:
			inventory[item_name] = new_amount
			emit_signal("inventory_changed", item_name, new_amount)
	else:
		# For non-natom items, no limit
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
