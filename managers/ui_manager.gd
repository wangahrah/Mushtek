extends Node

@onready var health_label = $health/Label
@onready var bioatoms_label = $bioatoms/Label
@onready var energy_labels = {}

func _ready() -> void:
	# Initialize energy tier labels
	for tier in NatomResource.Tier.values():
		var label_path = "energy_tier_" + str(tier) + "/Label"
		if has_node(label_path):
			energy_labels[tier] = get_node(label_path)
	
	# Connect to manager signals
	SceneManager.health_manager.health_changed.connect(_on_health_changed)
	SceneManager.inventory_manager.inventory_changed.connect(_on_inventory_changed)
	SceneManager.natom_manager.energy_drained.connect(_on_energy_drained)
	
	# Initialize labels with current values
	if SceneManager.health_manager:
		health_label.text = str(SceneManager.health_manager.current_health)
	if SceneManager.inventory_manager:
		# Initialize all natom tier labels
		for tier in NatomResource.Tier.values():
			var item_name = "natom_tier_" + str(tier)
			var quantity = SceneManager.inventory_manager.get_item_quantity(item_name)
			if tier == 0 and bioatoms_label:
				bioatoms_label.text = str(quantity)
			elif energy_labels.has(tier):
				energy_labels[tier].text = str(quantity)

func _on_health_changed(new_health: int) -> void:
	if health_label:
		health_label.text = str(new_health)

func _on_inventory_changed(item_name: String, quantity: int) -> void:
	if item_name.begins_with("natom_tier_"):
		var tier = int(item_name.split("_")[2])
		if tier == 0 and bioatoms_label:
			bioatoms_label.text = str(quantity)
		elif energy_labels.has(tier):
			energy_labels[tier].text = str(quantity)

func _on_energy_drained(tier: NatomResource.Tier, amount: float) -> void:
	if energy_labels.has(tier):
		energy_labels[tier].text = "%.1f" % amount 
