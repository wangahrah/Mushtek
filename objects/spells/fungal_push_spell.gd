extends BaseSpell
class_name FungalPushSpell

@export var fungal_push_scene: PackedScene
@export var spawn_distance: float = 30.0
@export var projectile_count: int = 5  # Number of projectiles to spawn
@export var spread_angle: float = 120.0  # Total spread angle in degrees

func _init() -> void:
	spell_name = "Fungal Push"
	natom_cost = 25
	cooldown = 1.0
	cast_range = 300.0
	spell_type = SpellType.PROJECTILE

func cast(caster: Node2D, target_position: Vector2) -> void:
	if not fungal_push_scene:
		push_error("Fungal Push scene not set in FungalPushSpell!")
		return
	
	# Calculate base direction to target
	var base_direction = (target_position - caster.global_position).normalized()
	var base_angle = base_direction.angle()
	
	# Calculate angle between projectiles
	var angle_step = deg_to_rad(spread_angle) / (projectile_count - 1)
	var start_angle = base_angle - deg_to_rad(spread_angle / 2)
	
	# Spawn projectiles in a cone
	for i in range(projectile_count):
		var angle = start_angle + (angle_step * i)
		var direction = Vector2(cos(angle), sin(angle))
		
		var fungal_push = fungal_push_scene.instantiate()
		caster.get_parent().add_child(fungal_push)
		
		var spawn_offset = Vector2(spawn_distance, 0)
		spawn_offset = spawn_offset.rotated(angle)
		fungal_push.global_position = caster.global_position + spawn_offset
		
		fungal_push.set_direction(direction) 
