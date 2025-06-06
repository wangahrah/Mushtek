extends CharacterBody2D
class_name Player

# Import spell classes
const FireballSpell = preload("res://objects/spells/fireball_spell.gd")
const LightningSpell = preload("res://objects/spells/lightning_spell.gd")
const FungalPushSpell = preload("res://objects/spells/fungal_push_spell.gd")

# Import UI scenes
const EquipmentUIScene = preload("res://objects/equipment_ui.tscn")

# Signals
signal player_died

# Constants
const HUNGER_INTERVAL: float = 1.0
const THROW_FORCE: float = 500.0
const COLLECTION_RANGE: float = 50.0

# Movement properties
@export var move_speed: float = 150
@export var acceleration: float = 500 
@export var friction: float = 400
@export var air_resistance: float = 0.95

# Spell system
@onready var spell_manager: SpellManager = $SpellManager

# Equipment system
@onready var equipment_ui: Control = null
var base_stats: Dictionary = {
	"health": 100,
	"speed": move_speed,
	"defense": 0,
	"attack": 10
}
var current_stats: Dictionary = {}

# Pickup properties
var carried_object: RigidBody2D = null
var pickup_offset: Vector2 = Vector2(0, -20)
var can_pickup: bool = true
var last_facing_direction: String = "down"

# Natom collection properties
var is_collecting: bool = false
var collection_target: Node2D = null

# Internal state
var hunger_timer: float = 0.0

@onready var collection_area: Area2D = $CollectionArea

# Lifecycle methods
func _ready() -> void:
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position
	
	Engine.max_fps = 60
	_initialize_game_state()
	_validate_collection_area()
	_initialize_spells()
	_initialize_equipment()
	_initialize_ui()

func _initialize_ui() -> void:
	print("DEBUG: Initializing EquipmentUI")
	# Create and add equipment UI
	equipment_ui = EquipmentUIScene.instantiate()
	if equipment_ui:
		print("DEBUG: EquipmentUI instantiated successfully")
		# Create a CanvasLayer for the UI
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 10  # Ensure it's above other layers
		add_child(canvas_layer)
		canvas_layer.add_child(equipment_ui)
		equipment_ui.hide()  # Start hidden
		print("DEBUG: EquipmentUI added to scene and hidden")
	else:
		print("ERROR: Failed to instantiate EquipmentUI")

func _initialize_equipment() -> void:
	# Set up equipment system
	EquipmentManager.set_player(self)
	
	# Initialize current stats with base stats
	current_stats = base_stats.duplicate()
	
	# Connect equipment change signal
	EquipmentManager.equipment_changed.connect(_on_equipment_changed)

func _on_equipment_changed(slot_type: int, item: EquipmentItem) -> void:
	print("DEBUG: Equipment changed signal received in player")
	print("DEBUG: Changed slot: ", slot_type)
	print("DEBUG: Changed item: ", item.item_name if item else "none")
	# Recalculate stats when equipment changes
	_recalculate_stats()

func _recalculate_stats() -> void:
	print("DEBUG: Recalculating stats")
	print("DEBUG: Base stats: ", base_stats)
	# Reset to base stats
	current_stats = base_stats.duplicate()
	print("DEBUG: Current stats after reset: ", current_stats)
	
	# Apply equipment stat changes
	for slot_type in EquipmentManager.equipped_items:
		var item = EquipmentManager.equipped_items[slot_type]
		if item:
			print("DEBUG: Applying stats from item: ", item.item_name)
			print("DEBUG: Item stat_changes dictionary: ", item.stat_changes)
			print("DEBUG: Item stat_changes type: ", typeof(item.stat_changes))
			print("DEBUG: Item stat_changes keys: ", item.stat_changes.keys())
			for stat in item.stat_changes:
				if stat == "speed":
					# Speed changes are now treated as absolute values
					current_stats[stat] = base_stats[stat] + item.get_stat_change(stat)
					print("DEBUG: New speed value: ", current_stats[stat])
				else:
					current_stats[stat] = current_stats.get(stat, 0) + item.get_stat_change(stat)
	
	print("DEBUG: Final current stats: ", current_stats)
	# Update movement speed
	move_speed = current_stats.speed
	print("DEBUG: Updated move_speed to: ", move_speed)

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	_handle_input()
	_handle_movement(input_vector, delta)
	_handle_animations()
	_handle_pushable_collisions()
	_handle_hunger(delta)
	
	move_and_slide()

# Initialization methods
func _initialize_game_state() -> void:
	SceneManager.set_player(self)

func _validate_collection_area() -> void:
	if not collection_area:
		push_error("CollectionArea node not found in player scene!")

func _initialize_spells() -> void:
	print("DEBUG: Initializing spells")
	# Create and add fireball spell
	var fireball_spell = FireballSpell.new()
	fireball_spell.fireball_scene = preload("res://objects/fireball.tscn")
	spell_manager.add_spell(fireball_spell)
	print("DEBUG: Added fireball spell")
	
	# Create and add lightning spell
	var lightning_spell = LightningSpell.new()
	lightning_spell.lightning_scene = preload("res://objects/lightning_bolt.tscn")
	spell_manager.add_spell(lightning_spell)
	print("DEBUG: Added lightning spell")
	
	# Create and add fungal push spell
	var fungal_push_spell = FungalPushSpell.new()
	fungal_push_spell.fungal_push_scene = preload("res://objects/fungal_push.tscn")
	spell_manager.add_spell(fungal_push_spell)
	print("DEBUG: Added fungal push spell")

# Input handling methods
func _handle_input() -> void:
	if Input.is_action_just_pressed("interact"):
		if carried_object == null:
			_try_pickup()
		else:
			_drop_object()
	elif Input.is_action_just_pressed("interact2") and carried_object != null:
		_throw_object()
	
	if Input.is_action_just_pressed("equipment_press"):
		_toggle_equipment_ui()
	
	if carried_object != null:
		_update_carried_object_position()

# Movement methods
func _handle_movement(input_vector: Vector2, delta: float) -> void:
	if input_vector != Vector2.ZERO:
		print("DEBUG: Current move_speed: ", move_speed)
		# Set velocity directly based on input and move_speed
		velocity = input_vector * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Apply air resistance
	velocity *= air_resistance

func _handle_pushable_collisions() -> void:
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider_node = collision.get_collider()
		
		if collider_node.is_in_group("pushable"): 
			var collision_normal: Vector2 = collision.get_normal()
			var push_force = -collision_normal * velocity.length() * 2
			
			if collider_node.has_method("apply_central_force"):
				collider_node.apply_central_force(push_force)
			elif collider_node.has_method("apply_impulse"):
				collider_node.apply_impulse(push_force)

# Animation methods
func _handle_animations() -> void:
	var anim_sprite = $AnimatedSprite2D
	
	if abs(velocity.x) > abs(velocity.y):
		_handle_horizontal_animation(anim_sprite)
	else:
		_handle_vertical_animation(anim_sprite)

func _handle_horizontal_animation(anim_sprite: AnimatedSprite2D) -> void:
	if velocity.x > 10:
		anim_sprite.play("move_right")
		$InteractArea.position = Vector2(5, 2)
		last_facing_direction = "right"
	elif velocity.x < -10:
		anim_sprite.play("move_left")
		$InteractArea.position = Vector2(-5, 2)
		last_facing_direction = "left"
	else:
		anim_sprite.stop()

func _handle_vertical_animation(anim_sprite: AnimatedSprite2D) -> void:
	if velocity.y < -10:
		anim_sprite.play("move_up")
		$InteractArea.position = Vector2(0, -4)
		last_facing_direction = "up"
	elif velocity.y > 10:
		anim_sprite.play("move_down")
		$InteractArea.position = Vector2(0, 8)
		last_facing_direction = "down"
	else:
		anim_sprite.stop()

# Game state methods
func _handle_hunger(delta: float) -> void:
	hunger_timer += delta
	if hunger_timer >= HUNGER_INTERVAL:
		hunger_timer = 0.0
		SceneManager.health_manager.take_damage(1)

# Object interaction methods
func _update_carried_object_position() -> void:
	if carried_object == null:
		return
		
	var offset = pickup_offset
	
	match last_facing_direction:
		"right":
			offset = Vector2(8, -5)
		"left":
			offset = Vector2(-8, -5)
		"up":
			offset = Vector2(0, -18)
		"down":
			offset = Vector2(0, 0)
	
	carried_object.global_position = global_position + offset

func _try_pickup() -> void:
	var interact_area = $InteractArea
	var overlapping_bodies = interact_area.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("pushable") and body is RigidBody2D:
			carried_object = body
			carried_object.freeze = true
			carried_object.collision_layer = 0
			carried_object.collision_mask = 0
			_update_carried_object_position()
			break

func _drop_object() -> void:
	if carried_object == null:
		return
		
	var final_position = carried_object.global_position
	
	carried_object.freeze = false
	carried_object.collision_layer = 1
	carried_object.collision_mask = 1
	carried_object.global_position = final_position
	
	carried_object = null

func _throw_object() -> void:
	if carried_object == null:
		return
		
	var mouse_pos = get_global_mouse_position()
	var throw_direction = (mouse_pos - global_position).normalized()
	var final_position = carried_object.global_position
	
	carried_object.freeze = false
	carried_object.collision_layer = 1
	carried_object.collision_mask = 1
	carried_object.global_position = final_position
	carried_object.apply_central_impulse(throw_direction * THROW_FORCE)
	
	carried_object = null

# Natom collection methods
func _try_collect_natoms() -> void:
	if not collection_area:
		return
		
	var overlapping_bodies = collection_area.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body == self:
			continue
			
		if body.is_in_group("natom_source"):
			collection_target = body
			is_collecting = true
			body.start_collection(self)
			break

# Signal handlers
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and body.has_method("set_interactable"):
		body.set_interactable(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable") and body.has_method("set_interactable"):
		body.set_interactable(false)

func _toggle_equipment_ui() -> void:
	print("DEBUG: Toggle EquipmentUI called")
	if equipment_ui:
		print("DEBUG: EquipmentUI exists, calling toggle_visibility")
		equipment_ui.toggle_visibility()
	else:
		print("ERROR: EquipmentUI is null")
