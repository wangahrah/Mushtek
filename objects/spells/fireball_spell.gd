extends BaseSpell
class_name FireballSpell

@export var fireball_scene: PackedScene
@export var spawn_distance: float = 30.0

func _init() -> void:
	spell_name = "Fireball"
	natom_cost = 5
	cooldown = 0.25
	cast_range = 300.0

func cast(caster: Node2D, target_position: Vector2) -> void:
	if not fireball_scene:
		push_error("Fireball scene not set in FireballSpell!")
		return
		
	var fireball = fireball_scene.instantiate()
	caster.get_parent().add_child(fireball)
	
	var direction = (target_position - caster.global_position).normalized()
	var spawn_offset = Vector2(spawn_distance, 0)
	spawn_offset = spawn_offset.rotated(direction.angle())
	fireball.global_position = caster.global_position + spawn_offset
	
	fireball.set_direction(direction) 
