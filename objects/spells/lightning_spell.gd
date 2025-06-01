extends BaseSpell
class_name LightningSpell

@export var lightning_scene: PackedScene
@export var spawn_distance: float = 30.0
@export var chain_count: int = 3  # Number of enemies the lightning can chain to
@export var chain_range: float = 100.0  # Maximum range for chaining
@export var chain_damage_reduction: float = 0.7  # Damage reduction per chain

func _init() -> void:
	spell_name = "Lightning Bolt"
	natom_cost = 15  # Higher cost than fireball due to chaining ability
	cooldown = 1.0   # Longer cooldown than fireball
	cast_range = 400.0  # Longer range than fireball
	spell_type = SpellType.PROJECTILE

func cast(caster: Node2D, target_position: Vector2) -> void:
	if not lightning_scene:
		push_error("Lightning scene not set in LightningSpell!")
		return
		
	var lightning = lightning_scene.instantiate()
	caster.get_parent().add_child(lightning)
	
	var direction = (target_position - caster.global_position).normalized()
	var spawn_offset = Vector2(spawn_distance, 0)
	spawn_offset = spawn_offset.rotated(direction.angle())
	lightning.global_position = caster.global_position + spawn_offset
	
	# Set chain properties
	lightning.chain_count = chain_count
	lightning.chain_range = chain_range
	lightning.chain_damage_reduction = chain_damage_reduction
	
	lightning.set_direction(direction) 
