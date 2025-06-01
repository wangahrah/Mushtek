extends Node

signal natom_collected(tier: NatomResource.Tier, amount: int)
signal energy_drained(tier: NatomResource.Tier, amount: float)
signal energy_depleted(tier: NatomResource.Tier)

var natom_resources: Dictionary = {}
var energy_levels: Dictionary = {}
const MAX_NATOMS: int = 500  # Maximum natoms player can hold

func _ready() -> void:
	# Initialize natom resources for each tier
	natom_resources = {
		NatomResource.Tier.TIER_1: NatomResource.new(NatomResource.Tier.TIER_1, "Basic Natom", "A fundamental energy unit"),
		NatomResource.Tier.TIER_2: NatomResource.new(NatomResource.Tier.TIER_2, "Advanced Natom", "An enhanced energy unit"),
		NatomResource.Tier.TIER_3: NatomResource.new(NatomResource.Tier.TIER_3, "Superior Natom", "A powerful energy unit"),
		NatomResource.Tier.TIER_4: NatomResource.new(NatomResource.Tier.TIER_4, "Elite Natom", "The most potent energy unit")
	}
	
	# Initialize energy levels
	for tier in natom_resources.keys():
		energy_levels[tier] = 100.0  # Start with 100 energy units

func _process(delta: float) -> void:
	# Process energy drain for equipped items
	_process_energy_drain(delta)

func add_natoms(tier: NatomResource.Tier, amount: int) -> void:
	# Check if adding would exceed max
	var current_amount = SceneManager.inventory_manager.get_item_quantity("natom_tier_" + str(tier))
	var new_amount = min(current_amount + amount, MAX_NATOMS)
	var actual_amount = new_amount - current_amount
	
	if actual_amount > 0:
		SceneManager.inventory_manager.add_item("natom_tier_" + str(tier), actual_amount)
		natom_collected.emit(tier, actual_amount)

func _process_energy_drain(delta: float) -> void:
	for tier in energy_levels.keys():
		var resource = natom_resources[tier]
		var drain_amount = resource.energy_drain_rate * delta
		
		if energy_levels[tier] > 0:
			energy_levels[tier] = max(0, energy_levels[tier] - drain_amount)
			# Only emit when energy is fully depleted
			if energy_levels[tier] <= 0:
				energy_depleted.emit(tier)

func get_energy_level(tier: NatomResource.Tier) -> float:
	return energy_levels.get(tier, 0.0)

func add_energy(tier: NatomResource.Tier, amount: float) -> void:
	energy_levels[tier] = min(100.0, energy_levels.get(tier, 0.0) + amount)

func get_natom_resource(tier: NatomResource.Tier) -> NatomResource:
	return natom_resources.get(tier) 
