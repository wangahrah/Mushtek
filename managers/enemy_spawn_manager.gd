extends Node

# Spawn configuration
@export var min_enemies: int = 1
@export var max_enemies: int = 3
@export var spawn_radius: float = 100.0  # How far from the center to spawn new ones
@export var enemy_scene: PackedScene
@export var max_spawn_attempts: int = 10  # Maximum attempts to find valid spawn location

# Internal state
var current_enemies: Array[Node2D] = []
var spawn_check_area: Area2D

func _ready() -> void:
	# Create and configure the spawn check timer
	var timer = Timer.new()
	timer.name = "SpawnCheckTimer"
	timer.wait_time = 2.0  # Check every 2 seconds
	timer.timeout.connect(_on_spawn_check_timer_timeout)
	add_child(timer)
	
	# Create spawn check area
	spawn_check_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)  # Adjust size based on your enemy size
	collision_shape.shape = shape
	spawn_check_area.add_child(collision_shape)
	add_child(spawn_check_area)
	
	# Get initial enemies
	_update_enemy_list()
	
	# Start checking for enemy count
	timer.start()

func _update_enemy_list() -> void:
	current_enemies.clear()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			# Only count enemies that were spawned by this manager
			if enemy.get_meta("spawned_by") == self:
				current_enemies.append(enemy)

func _on_spawn_check_timer_timeout() -> void:
	_update_enemy_list()
	
	# If we have fewer than min_enemies, spawn more
	if current_enemies.size() < min_enemies:
		var num_to_spawn = min_enemies - current_enemies.size()
		_spawn_enemies(num_to_spawn)

func _is_valid_spawn_location(pos: Vector2) -> bool:
	spawn_check_area.global_position = pos
	# Wait a frame to ensure physics has updated
	await get_tree().physics_frame
	# Check if the area is overlapping with any bodies
	return spawn_check_area.get_overlapping_bodies().size() == 0

func _find_valid_spawn_location() -> Vector2:
	var spawn_point = Vector2.ZERO
	var attempts = 0
	
	while attempts < max_spawn_attempts:
		# Calculate random position within spawn radius
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var test_position = spawn_point + offset
		
		if await _is_valid_spawn_location(test_position):
			return test_position
		
		attempts += 1
	
	# If we couldn't find a valid location, return the original spawn point
	# This is a fallback, but you might want to handle this case differently
	return spawn_point

func _spawn_enemies(count: int) -> void:
	if not enemy_scene:
		push_error("Enemy scene not set in spawn manager!")
		return
	
	# Spawn new enemies
	for i in range(count):
		var enemy = enemy_scene.instantiate()
		# Mark this enemy as spawned by this manager
		enemy.set_meta("spawned_by", self)
		get_tree().current_scene.add_child(enemy)
		
		# Find a valid spawn location
		var spawn_position = await _find_valid_spawn_location()
		enemy.global_position = spawn_position 
