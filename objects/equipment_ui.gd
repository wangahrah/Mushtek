extends Control

# References to UI elements
@onready var slot_buttons = {
	EquipmentManager.SlotType.HEAD: $MainContainer/VBoxContainer/HSplitContainer/LeftPanel/VBoxContainer/GridContainer/HeadSlot,
	EquipmentManager.SlotType.HANDS: $MainContainer/VBoxContainer/HSplitContainer/LeftPanel/VBoxContainer/GridContainer/HandsSlot,
	EquipmentManager.SlotType.BODY: $MainContainer/VBoxContainer/HSplitContainer/LeftPanel/VBoxContainer/GridContainer/BodySlot,
	EquipmentManager.SlotType.FEET: $MainContainer/VBoxContainer/HSplitContainer/LeftPanel/VBoxContainer/GridContainer/FeetSlot
}

@onready var item_list = $MainContainer/VBoxContainer/HSplitContainer/LeftPanel/VBoxContainer/ItemList
@onready var item_details = $MainContainer/VBoxContainer/HSplitContainer/RightPanel/ItemDetails
@onready var tier_buttons = {
	1: $MainContainer/VBoxContainer/TierContainer/Tier1Button,
	2: $MainContainer/VBoxContainer/TierContainer/Tier2Button,
	3: $MainContainer/VBoxContainer/TierContainer/Tier3Button,
	4: $MainContainer/VBoxContainer/TierContainer/Tier4Button,
	5: $MainContainer/VBoxContainer/TierContainer/Tier5Button
}

# Current state
var current_slot: int = -1
var current_tier: int = 1
var is_visible: bool = false

func _ready() -> void:
	print("DEBUG: EquipmentUI _ready called")
	# Connect slot button signals
	for slot_type in slot_buttons:
		var button = slot_buttons[slot_type]
		button.pressed.connect(_on_slot_pressed.bind(slot_type))
	
	# Connect tier button signals
	for tier in tier_buttons:
		var button = tier_buttons[tier]
		button.pressed.connect(_on_tier_pressed.bind(tier))
	
	# Connect item list selection signal
	item_list.item_selected.connect(_on_item_list_item_selected)
	
	# Connect equipment manager signals
	EquipmentManager.equipment_changed.connect(_on_equipment_changed)
	EquipmentManager.tier_unlocked.connect(_on_tier_unlocked)
	
	# Hide UI initially
	hide()
	print("DEBUG: EquipmentUI hidden on ready")
	
	# Update tier button states
	_update_tier_buttons()

func toggle_visibility() -> void:
	print("DEBUG: EquipmentUI toggle_visibility called, current state: ", is_visible)
	is_visible = !is_visible
	if is_visible:
		show()
		print("DEBUG: EquipmentUI shown")
		_update_slot_display()
	else:
		hide()
		print("DEBUG: EquipmentUI hidden")
		item_list.hide()
		item_details.hide()

func _on_slot_pressed(slot_type: int) -> void:
	print("DEBUG: Slot pressed: ", slot_type)
	current_slot = slot_type
	_show_available_items(slot_type)

func _on_tier_pressed(tier: int) -> void:
	current_tier = tier
	if current_slot != -1:
		_show_available_items(current_slot)

func _show_available_items(slot_type: int) -> void:
	print("DEBUG: Showing available items for slot ", slot_type, " tier ", current_tier)
	item_list.clear()
	
	var available_items = EquipmentManager.get_available_items(slot_type, current_tier)
	print("DEBUG: Found ", available_items.size(), " available items")
	
	# Debug print all available items
	print("DEBUG: Available items list:")
	for item in available_items:
		print("DEBUG: - ", item.item_name, " (Tier ", item.tier, ", Slot Type: ", item.slot_type, ")")
	
	for item in available_items:
		# Just show the item name without color tags
		print("DEBUG: Adding item to list: ", item.item_name)
		item_list.add_item(item.item_name, item.icon)
		print("DEBUG: Item added to list, current item count: ", item_list.item_count)
	
	item_list.show()
	print("DEBUG: ItemList visibility: ", item_list.visible)
	item_details.hide()

func _on_equipment_changed(slot_type: int, item: EquipmentItem) -> void:
	if is_visible:
		_update_slot_display()

func _on_tier_unlocked(tier: int) -> void:
	_update_tier_buttons()
	if is_visible and current_slot != -1:
		_show_available_items(current_slot)

func _update_tier_buttons() -> void:
	for tier in tier_buttons:
		var button = tier_buttons[tier]
		button.disabled = !EquipmentManager.is_tier_unlocked(tier)
		
		# Update button appearance based on current selection
		if tier == current_tier:
			button.modulate = Color(1, 1, 0)  # Yellow for selected
		else:
			button.modulate = Color(1, 1, 1)  # White for unselected

func _update_slot_display() -> void:
	print("DEBUG: Updating slot display")
	for slot_type in slot_buttons:
		var button = slot_buttons[slot_type]
		var equipped_item = EquipmentManager.get_equipped_item(slot_type)
		
		if equipped_item:
			# Just show the item name without color tags
			print("DEBUG: Slot ", slot_type, " has equipped item: ", equipped_item.item_name)
			button.text = equipped_item.item_name
		else:
			var slot_name = _get_slot_name(slot_type)
			print("DEBUG: Slot ", slot_type, " is empty, showing name: ", slot_name)
			button.text = slot_name

func _get_slot_name(slot_type: int) -> String:
	match slot_type:
		EquipmentManager.SlotType.HEAD: return "Head"
		EquipmentManager.SlotType.HANDS: return "Hands"
		EquipmentManager.SlotType.BODY: return "Body"
		EquipmentManager.SlotType.FEET: return "Feet"
		_: return "Unknown"

func _on_item_list_item_selected(index: int) -> void:
	print("DEBUG: Item selected at index: ", index)
	var slot_type = current_slot
	var available_items = EquipmentManager.get_available_items(slot_type, current_tier)
	
	if index >= 0 and index < available_items.size():
		var selected_item = available_items[index]
		print("DEBUG: Selected item: ", selected_item.item_name)
		_show_item_details(selected_item)
		
		# Equip the selected item
		if EquipmentManager.equip_item(selected_item):
			print("DEBUG: Successfully equipped item: ", selected_item.item_name)
		else:
			print("DEBUG: Failed to equip item: ", selected_item.item_name)
	else:
		print("DEBUG: Invalid item index: ", index)

func _show_item_details(item: EquipmentItem) -> void:
	print("DEBUG: Showing details for item: ", item.item_name)
	var tier_color = item.get_tier_color().to_html()
	item_details.text = """
	[color=%s]%s (Tier %d)[/color]
	
	%s
	
	Stats:
	%s
	
	Requirements:
	%s
	""" % [
		tier_color,
		item.item_name,
		item.tier,
		item.description,
		_format_stat_changes(item.stat_changes),
		_format_requirements(item.requirements)
	]
	
	item_details.show()
	print("DEBUG: ItemDetails visibility: ", item_details.visible)

func _format_stat_changes(stats: Dictionary) -> String:
	var text = ""
	for stat in stats:
		var value = stats[stat]
		text += "%s: %+d\n" % [stat, value]
	return text

func _format_requirements(reqs: Dictionary) -> String:
	var text = ""
	for req in reqs:
		var value = reqs[req]
		text += "%s: %d\n" % [req, value]
	return text 
