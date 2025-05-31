extends CharacterBody2D
class_name Player

@export var move_speed: float = 150
@export var acceleration: float = 500 
@export var friction: float = 400
@export var air_resistance: float = 0.95  # For floaty feel

signal health_changed(new_health: int)
signal player_died
signal energy_changed(tier: NatomResource.Tier, new_energy: float)

var hunger_timer: float = 0.0
const HUNGER_INTERVAL: float = 1.0  # Time in seconds between hunger ticks

# Spell casting variables
@export var fireball_scene: PackedScene  # This will be set in the editor
@export var fireball_spawn_distance: float = 30.0  # Distance from player to spawn fireball
@export var fireball_natom_cost: int = 5  # Cost in natoms to cast fireball
var can_cast: bool = true
@export var cast_cooldown: float = 0.5  # Time between casts in seconds
var cast_timer: float = 0.0

# Pickup variables
var carried_object: RigidBody2D = null
var pickup_offset: Vector2 = Vector2(0, -20)  # Offset from player where object is carried
var can_pickup: bool = true
var last_facing_direction: String = "down"  # Track last facing direction
const THROW_FORCE: float = 500.0  # Force applied when throwing

# Natom collection variables
var collection_range: float = 50.0  # Range at which player can collect natoms
var is_collecting: bool = false
var collection_target: Node2D = null

@onready var collection_area: Area2D = $CollectionArea

func _ready(): 
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position
	Engine.max_fps = 60
	update_health()  # Initialize health display at game start
	SceneManager.set_player(self)  # Register player with scene manager
	update_inventory()  # Initialize inventory display
	update_energy_display()  # Initialize energy display
	
	# Ensure collection area exists
	if not collection_area:
		push_error("CollectionArea node not found in player scene!")
	else:
		print("DEBUG: Collection area found with:")
		print("  - Layer: ", collection_area.collision_layer)
		print("  - Mask: ", collection_area.collision_mask)

func _physics_process(delta):
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Handle pickup/drop/throw
	if Input.is_action_just_pressed("interact"):
		print("DEBUG: Interact key pressed")
		if carried_object == null:
			_try_pickup()
		else:
			_drop_object()
	elif Input.is_action_just_pressed("interact2") and carried_object != null:
		_throw_object()
	
	# Update carried object position if we're carrying something
	if carried_object != null:
		_update_carried_object_position()
	
	# Apply acceleration when there's input
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Apply air resistance for floaty feel
	velocity *= air_resistance
	
	# Handle animations based on velocity direction
	handle_animations()
	
	# Handle collisions with pushable objects
	handle_pushable_collisions()
	
	# Handle hunger reduction
	hunger_timer += delta
	if hunger_timer >= HUNGER_INTERVAL:
		hunger_timer = 0.0
		take_damage(1)  # Reduce hunger by 1 point every second
	
	# Handle spell casting cooldown
	if not can_cast:
		cast_timer += delta
		if cast_timer >= cast_cooldown:
			can_cast = true
			cast_timer = 0.0
	
	# Handle spell casting
	if Input.is_action_just_pressed("cast_spell") and can_cast:
		cast_fireball()
	
	move_and_slide()
	update_inventory()
	update_health()
	update_energy_display()

func handle_animations():
	var anim_sprite = $AnimatedSprite2D
	
	# Use velocity instead of input for smoother animation transitions
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 10:
			anim_sprite.play("move_right")
			$InteractArea.position = Vector2(5,2)
			last_facing_direction = "right"
		elif velocity.x < -10:
			anim_sprite.play("move_left")
			$InteractArea.position = Vector2(-5,2)
			last_facing_direction = "left"
		else:
			anim_sprite.stop()
	else:
		if velocity.y < -10:
			anim_sprite.play("move_up")
			$InteractArea.position = Vector2(0,-4)
			last_facing_direction = "up"
		elif velocity.y > 10:
			anim_sprite.play("move_down")
			$InteractArea.position = Vector2(0,8)
			last_facing_direction = "down"
		else:
			anim_sprite.stop()

func handle_pushable_collisions():
	# Check all collisions, not just the last one
	for i in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider_node = collision.get_collider()
		
		if collider_node.is_in_group("pushable"): 
			var collision_normal: Vector2 = collision.get_normal()
			var push_force = -collision_normal * velocity.length() * 2
			
			# Apply force if the collider has the method
			if collider_node.has_method("apply_central_force"):
				collider_node.apply_central_force(push_force)
			elif collider_node.has_method("apply_impulse"):
				collider_node.apply_impulse(push_force)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable") and body.has_method("set_interactable"):
		body.set_interactable(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable") and body.has_method("set_interactable"):
		body.set_interactable(false)
		
func update_inventory():
	# Display TIER_1 natoms in the bioatoms label
	$CanvasLayer/bioatoms/Label.text = str(SceneManager.inventory_manager.get_item_quantity("natom_tier_0"))

func take_damage(amount: int) -> void:
	SceneManager.current_health = max(0, SceneManager.current_health - amount)
	health_changed.emit(SceneManager.current_health)
	update_health()
	
	if SceneManager.current_health <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	SceneManager.current_health = min(SceneManager.max_health, SceneManager.current_health + amount)
	health_changed.emit(SceneManager.current_health)
	update_health()

func get_health_percentage() -> float:
	return float(SceneManager.current_health) / float(SceneManager.max_health)

func update_health():
	$CanvasLayer/health/Label.text = str(SceneManager.current_health)

func cast_fireball() -> void:
	if not fireball_scene:
		push_error("Fireball scene not set in player!")
		return
	
	# Check if we have enough natoms
	var natom_cost = fireball_natom_cost
	if SceneManager.inventory_manager.get_item_quantity("natom_tier_0") < natom_cost:
		print("Not enough natoms to cast fireball!")
		return
		
	# Create new fireball instance
	var fireball = fireball_scene.instantiate()
	
	# Add it to the current scene
	get_parent().add_child(fireball)
	
	# Get mouse position for direction
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	
	# Set spawn position in front of player
	var spawn_offset = Vector2(fireball_spawn_distance, 0)
	spawn_offset = spawn_offset.rotated(direction.angle())
	fireball.global_position = global_position + spawn_offset
	
	# Set the fireball's direction
	fireball.set_direction(direction)
	
	# Spend natoms
	SceneManager.inventory_manager.remove_item("natom_tier_0", natom_cost)
	update_inventory()  # Update the UI to show new natom count
	
	# Start cooldown
	can_cast = false
	cast_timer = 0.0

func _update_carried_object_position() -> void:
	if carried_object == null:
		return
		
	var offset = pickup_offset
	
	# Adjust offset based on facing direction
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
	# Get all overlapping bodies in the interact area
	var interact_area = $InteractArea
	var overlapping_bodies = interact_area.get_overlapping_bodies()
	
	# Find the first pushable object
	for body in overlapping_bodies:
		if body.is_in_group("pushable") and body is RigidBody2D:
			carried_object = body
			# Disable physics while carried
			carried_object.freeze = true
			carried_object.collision_layer = 0  # Disable collisions while carried
			carried_object.collision_mask = 0
			_update_carried_object_position()  # Set initial position
			break

func _drop_object() -> void:
	if carried_object != null:
		# Store the final position before enabling physics
		var final_position = carried_object.global_position
		
		# Re-enable physics
		carried_object.freeze = false
		carried_object.collision_layer = 1  # Re-enable collisions
		carried_object.collision_mask = 1
		
		# Force the position to be exactly where it was carried
		carried_object.global_position = final_position
		
		carried_object = null

func _throw_object() -> void:
	if carried_object == null:
		return
		
	# Get mouse position in global coordinates
	var mouse_pos = get_global_mouse_position()
	
	# Calculate direction to mouse
	var throw_direction = (mouse_pos - global_position).normalized()
	
	# Store the final position before enabling physics
	var final_position = carried_object.global_position
	
	# Re-enable physics
	carried_object.freeze = false
	carried_object.collision_layer = 1  # Re-enable collisions
	carried_object.collision_mask = 1
	
	# Force the position to be exactly where it was carried
	carried_object.global_position = final_position
	
	# Apply throw force in the direction of the mouse
	carried_object.apply_central_impulse(throw_direction * THROW_FORCE)
	
	carried_object = null

func _try_collect_natoms() -> void:
	if not collection_area:
		print("DEBUG: Collection area is null!")
		return
		
	var overlapping_bodies = collection_area.get_overlapping_bodies()
	print("DEBUG: Found ", overlapping_bodies.size(), " overlapping bodies in collection area")
	print("DEBUG: Collection area position: ", collection_area.global_position)
	print("DEBUG: Collection area collision layer: ", collection_area.collision_layer)
	print("DEBUG: Collection area collision mask: ", collection_area.collision_mask)
	
	for body in overlapping_bodies:
		print("DEBUG: Checking body: ", body.name)
		print("DEBUG: Body collision layer: ", body.collision_layer if body.has_method("get_collision_layer") else "N/A")
		# Skip if the body is the player
		if body == self:
			print("DEBUG: Skipping player body")
			continue
			
		if body.is_in_group("natom_source"):
			print("DEBUG: Found natom source, starting collection")
			collection_target = body
			is_collecting = true
			# Start collection process
			body.start_collection(self)
			break
		else:
			print("DEBUG: Found body but not a natom source: ", body.name)

func update_energy_display() -> void:
	for tier in NatomResource.Tier.values():
		var energy = SceneManager.natom_manager.get_energy_level(tier)
		energy_changed.emit(tier, energy)
		# Update UI elements here
		if has_node("CanvasLayer/energy_tier_" + str(tier)):
			$CanvasLayer/health/Label.get_node("energy_tier_" + str(tier)).text = "%.1f" % energy
	
	# Display TIER_1 natoms in health label
	var tier1_energy = SceneManager.natom_manager.get_energy_level(NatomResource.Tier.TIER_1)
	$CanvasLayer/health/Label.text = str(int(tier1_energy))

func on_energy_depleted(tier: NatomResource.Tier) -> void:
	# Handle energy depletion effects
	print("Energy depleted for tier %d" % tier)
	# Implement effects like reduced movement speed, damage, etc.
