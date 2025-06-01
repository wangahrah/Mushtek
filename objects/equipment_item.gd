extends Resource
class_name EquipmentItem

# Basic properties
@export var item_name: String
@export var description: String
@export var slot_type: int  # Will use EquipmentManager.SlotType
@export var is_unlocked: bool = false
@export var tier: int = 1  # Equipment tier (1-5)

# Visual properties
@export var icon: Texture2D
@export var model_scene: PackedScene  # For 3D models if needed

# Gameplay properties
@export var weapon_scene: PackedScene  # For weapons/equipment that need to be attached
@export var stat_changes: Dictionary = {}  # e.g. {"health": 10, "speed": 5}
@export var requirements: Dictionary = {}  # e.g. {"level": 5, "strength": 10}

# Additional properties
@export var rarity: int = 1  # 1-5 for common to legendary
@export var durability: float = 100.0
@export var max_durability: float = 100.0

# Tier-based stat multipliers
const TIER_MULTIPLIERS = {
	1: 1.0,    # Base stats
	2: 1.5,    # 50% better than tier 1
	3: 2.0,    # 100% better than tier 1
	4: 2.5,    # 150% better than tier 1
	5: 3.0     # 200% better than tier 1
}

func _init() -> void:
	# Initialize with default values
	pass

func get_stat_change(stat_name: String) -> float:
	var base_value = stat_changes.get(stat_name, 0.0)
	return base_value * TIER_MULTIPLIERS.get(tier, 1.0)

func get_requirement(req_name: String) -> float:
	return requirements.get(req_name, 0.0)

func is_equippable() -> bool:
	return is_unlocked and durability > 0

func take_damage(amount: float) -> void:
	durability = max(0.0, durability - amount)

func repair(amount: float) -> void:
	durability = min(max_durability, durability + amount)

func get_tier_color() -> Color:
	match tier:
		1: return Color(0.7, 0.7, 0.7)  # Gray
		2: return Color(0.0, 0.8, 0.0)  # Green
		3: return Color(0.0, 0.5, 1.0)  # Blue
		4: return Color(0.8, 0.0, 0.8)  # Purple
		5: return Color(1.0, 0.5, 0.0)  # Orange
		_: return Color(1.0, 1.0, 1.0)  # White 