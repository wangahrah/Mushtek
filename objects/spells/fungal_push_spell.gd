extends BaseSpell
class_name FungalPushSpell

@export var fungal_push_scene: PackedScene
@export var spawn_distance: float = 30.0

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
        
    var fungal_push = fungal_push_scene.instantiate()
    caster.get_parent().add_child(fungal_push)
    
    var direction = (target_position - caster.global_position).normalized()
    var spawn_offset = Vector2(spawn_distance, 0)
    spawn_offset = spawn_offset.rotated(direction.angle())
    fungal_push.global_position = caster.global_position + spawn_offset
    
    fungal_push.set_direction(direction) 