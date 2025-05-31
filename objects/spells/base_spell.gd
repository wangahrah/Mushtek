extends Node
class_name BaseSpell

enum SpellType {
	PROJECTILE,    # Spells that create moving projectiles
	AREA_EFFECT,   # Spells that affect an area
	BUFF_DEBUFF,   # Spells that modify entity properties
	SUMMON,        # Spells that create temporary entities
	CHANNELED,     # Spells that require continuous casting
	INSTANT        # Spells that take effect immediately
}

# Base properties all spells should have
@export var spell_name: String = "Unnamed Spell"
@export var spell_icon: Texture2D
@export var spell_type: SpellType = SpellType.INSTANT
@export var natom_cost: int = 5
@export var cooldown: float = 0.5
@export var cast_range: float = 300.0

# Area of effect properties
@export var has_area_effect: bool = false
@export var area_radius: float = 100.0
@export var area_shape: Shape2D  # For custom area shapes

# Duration and tick properties
@export var duration: float = 0.0  # 0 means instant
@export var tick_rate: float = 0.0  # 0 means no ticks
@export var max_ticks: int = 0  # 0 means unlimited

# Targeting properties
@export var requires_target: bool = false
@export var can_target_self: bool = false
@export var can_target_enemies: bool = true
@export var can_target_allies: bool = false
@export var can_target_terrain: bool = false

# State
var is_on_cooldown: bool = false
var cooldown_timer: float = 0.0
var current_duration: float = 0.0
var current_ticks: int = 0
var is_channeling: bool = false

# Virtual methods that derived spells must implement
func cast(caster: Node2D, target_position: Vector2) -> void:
	push_error("cast() method not implemented in derived spell class")

# Optional virtual methods that derived spells can override
func on_tick(caster: Node2D, target_position: Vector2) -> void:
	pass

func on_start(caster: Node2D, target_position: Vector2) -> void:
	pass

func on_end(caster: Node2D, target_position: Vector2) -> void:
	pass

func can_target(target: Node2D) -> bool:
	if not requires_target:
		return true
		
	if target == get_parent() and not can_target_self:
		return false
		
	# Add more target validation logic here based on your game's entity system
	return true

func _process(delta: float) -> void:
	if is_on_cooldown:
		cooldown_timer += delta
		if cooldown_timer >= cooldown:
			is_on_cooldown = false
			cooldown_timer = 0.0
	
	if duration > 0 and current_duration > 0:
		current_duration -= delta
		if tick_rate > 0 and current_ticks < max_ticks:
			var tick_timer = fmod(current_duration, tick_rate)
			if tick_timer < delta:
				on_tick(get_parent(), get_parent().get_global_mouse_position())
				current_ticks += 1
		
		if current_duration <= 0:
			on_end(get_parent(), get_parent().get_global_mouse_position())
			current_duration = 0
			current_ticks = 0

# Helper methods
func start_cooldown() -> void:
	is_on_cooldown = true
	cooldown_timer = 0.0

func start_duration() -> void:
	if duration > 0:
		current_duration = duration
		current_ticks = 0
		on_start(get_parent(), get_parent().get_global_mouse_position())

func can_cast() -> bool:
	return not is_on_cooldown and SceneManager.inventory_manager.get_item_quantity("natom_tier_0") >= natom_cost

func consume_natoms() -> void:
	SceneManager.inventory_manager.remove_item("natom_tier_0", natom_cost)

# Area of effect helpers
func get_area_overlap() -> Array:
	if not has_area_effect:
		return []
		
	var area = Area2D.new()
	if area_shape:
		var collision = CollisionShape2D.new()
		collision.shape = area_shape
		area.add_child(collision)
	else:
		var collision = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = area_radius
		collision.shape = circle
		area.add_child(collision)
	
	# Add area to scene tree temporarily
	get_tree().root.add_child(area)
	var overlapping_bodies = area.get_overlapping_bodies()
	area.queue_free()
	return overlapping_bodies 