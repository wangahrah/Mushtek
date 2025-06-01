extends Node

# Equipment slots
enum SlotType {
	HEAD,
	HANDS,
	BODY,
	FEET
}

# Signal when equipment changes
signal equipment_changed(slot_type: SlotType, item: EquipmentItem)
signal tier_unlocked(tier: int)

# Currently equipped items
var equipped_items: Dictionary = {
	SlotType.HEAD: null,
	SlotType.HANDS: null,
	SlotType.BODY: null,
	SlotType.FEET: null
}

# Available equipment items by slot and tier
var available_items: Dictionary = {
	SlotType.HEAD: {},
	SlotType.HANDS: {},
	SlotType.BODY: {},
	SlotType.FEET: {}
}

# Unlocked tiers
var unlocked_tiers: Array[int] = [1]  # Start with tier 1 unlocked

# Player reference
var player: Node = null

func _ready() -> void:
	# Initialize available items
	_initialize_available_items()

func set_player(player_node: Node) -> void:
	print("DEBUG: Setting player reference in EquipmentManager")
	player = player_node
	print("DEBUG: Player reference set: ", player != null)

func _initialize_available_items() -> void:
	print("DEBUG: Initializing available items")
	# Initialize empty tier dictionaries for each slot
	for slot in available_items:
		available_items[slot] = {
			1: [],  # Tier 1 items
			2: [],  # Tier 2 items
			3: [],  # Tier 3 items
			4: [],  # Tier 4 items
			5: []   # Tier 5 items
		}
	
	# Load all items from the equipment directory
	var dir = DirAccess.open("res://resources/equipment")
	if dir:
		print("DEBUG: Successfully opened equipment directory")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("DEBUG: Checking file: ", file_name)
			if file_name.ends_with(".tres"):
				print("DEBUG: Found .tres file: ", file_name)
				var item_path = "res://resources/equipment/" + file_name
				print("DEBUG: Attempting to load item from: ", item_path)
				var item = load(item_path)
				if item:
					print("DEBUG: Successfully loaded item: ", item.item_name, " (Tier ", item.tier, ", Slot Type: ", item.slot_type, ")")
					add_item(item)
				else:
					print("ERROR: Failed to load item from: ", item_path)
			file_name = dir.get_next()
		print("DEBUG: Finished loading all items")
		
		# Print summary of loaded items
		print("DEBUG: Summary of loaded items:")
		for slot_type in available_items:
			print("DEBUG: Slot ", slot_type, " items:")
			for tier in available_items[slot_type]:
				var items = available_items[slot_type][tier]
				if items.size() > 0:
					print("DEBUG: - Tier ", tier, ":")
					for item in items:
						print("DEBUG:   - ", item.item_name)
	else:
		print("ERROR: Could not open equipment directory")

func _get_slot_name(slot_type: SlotType) -> String:
	match slot_type:
		SlotType.HEAD: return "Head"
		SlotType.HANDS: return "Hands"
		SlotType.BODY: return "Body"
		SlotType.FEET: return "Feet"
		_: return "Unknown"

func _get_slot_type(slot_name: String) -> int:
	match slot_name.to_lower():
		"head": return SlotType.HEAD
		"hands": return SlotType.HANDS
		"body": return SlotType.BODY
		"feet": return SlotType.FEET
		_: return -1

func _load_base_items(slot_name: String) -> void:
	print("DEBUG: Loading items for slot: ", slot_name)
	var slot_type = _get_slot_type(slot_name)
	if slot_type == -1:
		print("ERROR: Invalid slot name: ", slot_name)
		return
		
	# Load all items for this slot type
	var dir = DirAccess.open("res://resources/equipment")
	if dir:
		print("DEBUG: Successfully opened equipment directory")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("DEBUG: Checking file: ", file_name)
			if file_name.ends_with(".tres"):
				print("DEBUG: Found .tres file: ", file_name)
				# Check if file contains slot name or is a base item for this slot
				if file_name.contains(slot_name) or file_name.begins_with("base_" + slot_name):
					print("DEBUG: File matches slot criteria: ", slot_name)
					var item_path = "res://resources/equipment/" + file_name
					print("DEBUG: Attempting to load item from: ", item_path)
					var item = load(item_path)
					if item:
						print("DEBUG: Successfully loaded item: ", item.item_name, " (Tier ", item.tier, ")")
						if item.slot_type == slot_type:
							print("DEBUG: Item slot type matches: ", item.slot_type)
							add_item(item)
							print("DEBUG: Item added to available items")
						else:
							print("DEBUG: Item slot type mismatch. Expected: ", slot_type, " Got: ", item.slot_type)
					else:
						print("ERROR: Failed to load item from: ", item_path)
				else:
					print("DEBUG: File does not match slot criteria: ", slot_name)
			file_name = dir.get_next()
		print("DEBUG: Finished loading items for slot: ", slot_name)
		# Print all available items for this slot
		print("DEBUG: Current available items for slot ", slot_name, ":")
		for tier in available_items[slot_type]:
			print("DEBUG: Tier ", tier, " items:")
			for item in available_items[slot_type][tier]:
				print("DEBUG: - ", item.item_name)
	else:
		print("ERROR: Could not open equipment directory")

func unlock_tier(tier: int) -> void:
	if tier > 1 and tier <= 5 and not unlocked_tiers.has(tier):
		unlocked_tiers.append(tier)
		unlocked_tiers.sort()  # Keep tiers in order
		emit_signal("tier_unlocked", tier)

func is_tier_unlocked(tier: int) -> bool:
	return unlocked_tiers.has(tier)

func get_available_items(slot_type: SlotType, tier: int = -1) -> Array:
	print("DEBUG: Getting available items for slot type: ", slot_type, " tier: ", tier)
	if tier == -1:
		# Return all available items for the slot
		var all_items = []
		for tier_items in available_items[slot_type].values():
			all_items.append_array(tier_items)
		print("DEBUG: Returning all items for slot: ", all_items.size(), " items found")
		for item in all_items:
			print("DEBUG: Available item: ", item.item_name, " (Tier ", item.tier, ")")
		return all_items
	else:
		# Return items for specific tier
		var tier_items = available_items[slot_type].get(tier, [])
		print("DEBUG: Returning tier ", tier, " items: ", tier_items.size(), " items found")
		for item in tier_items:
			print("DEBUG: Available item: ", item.item_name, " (Tier ", item.tier, ")")
		return tier_items

func add_item(item: EquipmentItem) -> void:
	print("DEBUG: Adding item to available items: ", item.item_name, " (Tier ", item.tier, ", Slot Type: ", item.slot_type, ")")
	if not available_items[item.slot_type].has(item.tier):
		print("DEBUG: Creating new tier array for slot ", item.slot_type, " tier ", item.tier)
		available_items[item.slot_type][item.tier] = []
	available_items[item.slot_type][item.tier].append(item)
	print("DEBUG: Current items for slot ", item.slot_type, " tier ", item.tier, ": ", available_items[item.slot_type][item.tier].size())
	print("DEBUG: All items in this tier:")
	for existing_item in available_items[item.slot_type][item.tier]:
		print("DEBUG: - ", existing_item.item_name)

func equip_item(item: EquipmentItem) -> bool:
	print("DEBUG: Attempting to equip item: ", item.item_name)
	if not item or not _can_equip_item(item):
		print("DEBUG: Cannot equip item - item is null or requirements not met")
		return false
		
	# Check if this item is already equipped
	var current_item = equipped_items[item.slot_type]
	if current_item == item:
		print("DEBUG: Item is already equipped, refreshing visual")
		_apply_item_effects(item)  # Re-apply effects to refresh visual
		return true
		
	# Unequip current item in that slot if any
	unequip_item(item.slot_type)
	
	# Equip new item
	equipped_items[item.slot_type] = item
	print("DEBUG: Item added to equipped_items dictionary")
	
	# Apply item effects to player
	_apply_item_effects(item)
	
	# Emit signal
	emit_signal("equipment_changed", item.slot_type, item)
	print("DEBUG: Equipment changed signal emitted")
	
	return true

func unequip_item(slot_type: SlotType) -> void:
	var current_item = equipped_items[slot_type]
	if current_item:
		# Remove item effects from player
		_remove_item_effects(current_item)
		
		# Clear slot
		equipped_items[slot_type] = null
		
		# Emit signal
		emit_signal("equipment_changed", slot_type, null)

func _can_equip_item(item: EquipmentItem) -> bool:
	# Check if item is unlocked
	if not item.is_unlocked:
		return false
		
	# Check if tier is unlocked
	if not is_tier_unlocked(item.tier):
		return false
		
	# Check if player meets requirements
	if not _meets_requirements(item):
		return false
		
	return true

func _meets_requirements(item: EquipmentItem) -> bool:
	# TODO: Implement requirement checking
	# This will check if player meets level, stats, or other requirements
	return true

func _apply_item_effects(item: EquipmentItem) -> void:
	print("DEBUG: Applying effects for item: ", item.item_name)
	if not player:
		print("ERROR: Player reference is null")
		return
	print("DEBUG: Player reference is valid")
		
	# Apply stat changes
	for stat in item.stat_changes:
		# TODO: Implement stat modification
		pass
		
	# Attach weapon/equipment scene or icon
	print("DEBUG: Calling _attach_weapon for item: ", item.item_name)
	_attach_weapon(item)

func _remove_item_effects(item: EquipmentItem) -> void:
	if not player:
		return
		
	# Remove stat changes
	for stat in item.stat_changes:
		# TODO: Implement stat removal
		pass
		
	# Remove weapon/equipment scene or icon
	_detach_weapon(item)

func _attach_weapon(item: EquipmentItem) -> void:
	print("DEBUG: _attach_weapon called for item: ", item.item_name)
	if not player:
		print("ERROR: Player reference is null in _attach_weapon")
		return
	print("DEBUG: Player reference is valid in _attach_weapon")
		
	# Get the appropriate slot
	var slot_name = _get_slot_name(item.slot_type).to_lower()
	print("DEBUG: Looking for slot: ", slot_name)
	var slot_path = "EquipmentSlots/" + slot_name
	print("DEBUG: Full slot path: ", slot_path)
	var slot = player.get_node(slot_path)
	
	if not slot:
		print("ERROR: Equipment slot not found: ", slot_path)
		print("DEBUG: Player node path: ", player.get_path())
		print("DEBUG: Available children: ", player.get_children())
		return
	print("DEBUG: Found slot node: ", slot.name)
	
	# Clear any existing equipment (except the Sprite2D)
	for child in slot.get_children():
		if child is Node2D and not child is Sprite2D:
			print("DEBUG: Removing existing equipment: ", child.name)
			child.queue_free()
	
	# Handle model scene if it exists
	if item.model_scene:
		print("DEBUG: Item has model_scene, instantiating")
		var equipment_instance = item.model_scene.instantiate()
		slot.add_child(equipment_instance)
	
	# Handle icon if it exists
	if item.icon:
		print("DEBUG: Item has icon, updating sprite")
		var sprite = slot.get_node_or_null("Sprite2D")
		if sprite:
			print("DEBUG: Found Sprite2D, setting texture and making visible")
			sprite.texture = item.icon
			sprite.visible = true
			sprite.scale = Vector2(1, 1)  # Reset scale
			sprite.modulate = item.color_tint  # Use the item's color tint
			print("DEBUG: Sprite texture set to: ", item.icon.resource_path)
			print("DEBUG: Sprite properties - visible: ", sprite.visible, ", scale: ", sprite.scale, ", modulate: ", sprite.modulate)
		else:
			print("ERROR: Sprite2D not found in slot ", slot_name)
			print("DEBUG: Slot children: ", slot.get_children())
	else:
		print("DEBUG: Item has no icon")
			
	# Update animations if needed
	var anim_player = slot.get_node_or_null("AnimationPlayer")
	if anim_player and item.animation_name:
		print("DEBUG: Playing animation: ", item.animation_name)
		anim_player.play(item.animation_name)

func _detach_weapon(item: EquipmentItem) -> void:
	if not player:
		return
		
	var slot_name = _get_slot_name(item.slot_type).to_lower()
	var slot = player.get_node("EquipmentSlots/" + slot_name)
	
	if not slot:
		return
		
	# Clear equipment (except the Sprite2D)
	for child in slot.get_children():
		if child is Node2D and not child is Sprite2D:
			child.queue_free()
			
	# Reset sprite if it exists
	var sprite = slot.get_node_or_null("Sprite2D")
	if sprite:
		sprite.texture = null
		sprite.visible = false
		
	# Stop animations
	var anim_player = slot.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.stop()

func get_equipped_item(slot_type: SlotType) -> EquipmentItem:
	return equipped_items[slot_type]

func get_highest_unlocked_tier() -> int:
	return unlocked_tiers.max() if unlocked_tiers.size() > 0 else 1
