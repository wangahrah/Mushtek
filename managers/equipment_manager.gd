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
	initialize_available_items()

func set_player(player_node: Node) -> void:
	print("DEBUG: Setting player reference in EquipmentManager")
	player = player_node
	print("DEBUG: Player reference set: ", player != null)

func reload_items() -> void:
	# Clear current items
	for slot in available_items:
		available_items[slot] = {
			1: [],  # Tier 1 items
			2: [],  # Tier 2 items
			3: [],  # Tier 3 items
			4: [],  # Tier 4 items
			5: []   # Tier 5 items
		}
	# Reload items
	initialize_available_items()

func initialize_available_items() -> void:
	print("DEBUG: EquipmentManager.initialize_available_items - Starting item initialization")
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
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item_path = "res://resources/equipment/" + file_name
				print("DEBUG: EquipmentManager - Loading item from: ", item_path)
				var item = load(item_path)
				if item:
					print("DEBUG: EquipmentManager - Loaded item: ", item.item_name, " stat_changes: ", item.stat_changes)
					add_item(item)
			file_name = dir.get_next()
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
	if tier == -1:
		# Return all available items for the slot
		var all_items = []
		for tier_items in available_items[slot_type].values():
			all_items.append_array(tier_items)
		return all_items
	else:
		# Return items for specific tier
		var tier_items = available_items[slot_type].get(tier, [])
		return tier_items

func add_item(item: EquipmentItem) -> void:
	print("DEBUG: EquipmentManager.add_item - Adding item: ", item.item_name)
	print("DEBUG: EquipmentManager.add_item - Item stat_changes before add: ", item.stat_changes)
	if not available_items[item.slot_type].has(item.tier):
		available_items[item.slot_type][item.tier] = []
	available_items[item.slot_type][item.tier].append(item)
	print("DEBUG: EquipmentManager.add_item - Item added to slot ", item.slot_type, " tier ", item.tier)
	print("DEBUG: EquipmentManager.add_item - Current items in this tier: ", available_items[item.slot_type][item.tier].size())

func equip_item(item: EquipmentItem) -> bool:
	print("DEBUG: EquipmentManager.equip_item - Attempting to equip: ", item.item_name)
	print("DEBUG: EquipmentManager.equip_item - Item stat_changes: ", item.stat_changes)
	if not item or not _can_equip_item(item):
		return false
		
	# Check if this item is already equipped
	var current_item = equipped_items[item.slot_type]
	if current_item == item:
		_apply_item_effects(item)  # Re-apply effects to refresh visual
		return true
		
	# Unequip current item in that slot if any
	unequip_item(item.slot_type)
	
	# Equip new item
	equipped_items[item.slot_type] = item
	print("DEBUG: EquipmentManager.equip_item - Item equipped, current equipped_items: ", equipped_items)
	
	# Apply item effects to player
	_apply_item_effects(item)
	
	# Emit signal
	emit_signal("equipment_changed", item.slot_type, item)
	
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
	if not player:
		print("ERROR: Player reference is null")
		return
		
	# Attach weapon/equipment scene or icon
	_attach_weapon(item)

func _remove_item_effects(item: EquipmentItem) -> void:
	if not player:
		return
		
	# Remove weapon/equipment scene or icon
	_detach_weapon(item)

func _attach_weapon(item: EquipmentItem) -> void:
	if not player:
		print("ERROR: Player reference is null in _attach_weapon")
		return
		
	# Get the appropriate slot
	var slot_name = _get_slot_name(item.slot_type).to_lower()
	var slot_path = "EquipmentSlots/" + slot_name
	var slot = player.get_node(slot_path)
	
	if not slot:
		print("ERROR: Equipment slot not found: ", slot_path)
		return
	
	# Clear any existing equipment (except the Sprite2D)
	for child in slot.get_children():
		if child is Node2D and not child is Sprite2D:
			child.queue_free()
	
	# Handle model scene if it exists
	if item.model_scene:
		var equipment_instance = item.model_scene.instantiate()
		slot.add_child(equipment_instance)
	
	# Handle icon if it exists
	if item.icon:
		var sprite = slot.get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = item.icon
			sprite.visible = true
			sprite.scale = Vector2(1, 1)  # Reset scale
			sprite.modulate = item.color_tint  # Use the item's color tint
			
	# Update animations if needed
	var anim_player = slot.get_node_or_null("AnimationPlayer")
	if anim_player and item.animation_name:
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
