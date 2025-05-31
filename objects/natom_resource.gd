extends Resource
class_name NatomResource

enum Tier { TIER_1, TIER_2, TIER_3, TIER_4 }

@export var tier: Tier = Tier.TIER_1
@export var name: String = "Basic Natom"
@export var description: String = "A basic natom unit"
@export var energy_drain_rate: float = 0.1  # Energy units per second
@export var collection_rate: float = 1.0    # Collection speed multiplier
@export var value: int = 1                  # Base value for crafting

func _init(p_tier: Tier = Tier.TIER_1, p_name: String = "", p_description: String = "") -> void:
	tier = p_tier
	if p_name != "":
		name = p_name
	if p_description != "":
		description = p_description
	
	# Set tier-specific properties
	match tier:
		Tier.TIER_1:
			energy_drain_rate = 0.1
			collection_rate = 1.0
			value = 1
		Tier.TIER_2:
			energy_drain_rate = 0.2
			collection_rate = 1.5
			value = 5
		Tier.TIER_3:
			energy_drain_rate = 0.4
			collection_rate = 2.0
			value = 25
		Tier.TIER_4:
			energy_drain_rate = 0.8
			collection_rate = 3.0
			value = 100

func get_tier_name() -> String:
	match tier:
		Tier.TIER_1: return "Tier 1"
		Tier.TIER_2: return "Tier 2"
		Tier.TIER_3: return "Tier 3"
		Tier.TIER_4: return "Tier 4"
		_: return "Unknown" 