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
	player = player_node

func _initialize_available_items() -> void:
	# Initialize empty tier dictionaries for each slot
	for slot in available_items:
		available_items[slot] = {
			1: [],  # Tier 1 items
			2: [],  # Tier 2 items
			3: [],  # Tier 3 items
			4: [],  # Tier 4 items
			5: []   # Tier 5 items
		}
	
	# Load base items for all slots
	_load_base_items("head")
	_load_base_items("hands")
	_load_base_items("body")
	_load_base_items("feet")

func _load_base_items(slot_name: String) -> void:
	print("DEBUG: Loading base items for slot: ", slot_name)
	var slot_type = _get_slot_type(slot_name)
	if slot_type == -1:
		print("ERROR: Invalid slot name: ", slot_name)
		return
		
	# Load items for each tier
	for tier in range(1, 6):
		var item_path = "res://resources/equipment/base_%s_t%d.tres" % [slot_name, tier]
		print("DEBUG: Attempting to load item from: ", item_path)
		var item = load(item_path)
		if item:
			print("DEBUG: Successfully loaded item: ", item.item_name)
			add_item(item)
		else:
			print("ERROR: Failed to load item from: ", item_path)

func _get_slot_type(slot_name: String) -> int:
	match slot_name.to_lower():
		"head": return SlotType.HEAD
		"hands": return SlotType.HANDS
		"body": return SlotType.BODY
		"feet": return SlotType.FEET
		_: return -1

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
		return available_items[slot_type].get(tier, [])

func add_item(item: EquipmentItem) -> void:
	print("DEBUG: Adding item to available items: ", item.item_name, " (Tier ", item.tier, ")")
	if not available_items[item.slot_type].has(item.tier):
		available_items[item.slot_type][item.tier] = []
	available_items[item.slot_type][item.tier].append(item)
	print("DEBUG: Current items for slot ", item.slot_type, " tier ", item.tier, ": ", available_items[item.slot_type][item.tier].size())

func equip_item(item: EquipmentItem) -> bool:
	if not item or not _can_equip_item(item):
		return false
		
	# Unequip current item in that slot if any
	unequip_item(item.slot_type)
	
	# Equip new item
	equipped_items[item.slot_type] = item
	
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
		return
		
	# Apply stat changes
	for stat in item.stat_changes:
		# TODO: Implement stat modification
		pass
		
	# Attach weapon/equipment scene if needed
	if item.weapon_scene:
		_attach_weapon(item)

func _remove_item_effects(item: EquipmentItem) -> void:
	if not player:
		return
		
	# Remove stat changes
	for stat in item.stat_changes:
		# TODO: Implement stat removal
		pass
		
	# Remove weapon/equipment scene if needed
	if item.weapon_scene:
		_detach_weapon(item)

func _attach_weapon(item: EquipmentItem) -> void:
	# TODO: Implement weapon attachment
	pass

func _detach_weapon(item: EquipmentItem) -> void:
	# TODO: Implement weapon detachment
	pass

func get_equipped_item(slot_type: SlotType) -> EquipmentItem:
	return equipped_items[slot_type]

func get_highest_unlocked_tier() -> int:
	return unlocked_tiers.max() if unlocked_tiers.size() > 0 else 1 
