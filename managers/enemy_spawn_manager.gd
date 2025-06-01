extends Node

# Spawn configuration
@export var min_enemies: int = 1
@export var max_enemies: int = 3
@export var spawn_radius: float = 100.0  # How far from the last enemy to spawn new ones
@export var enemy_scene: PackedScene

# Internal state
var current_enemies: Array[Node2D] = []

func _ready() -> void:
	# Create and configure the spawn check timer
	var timer = Timer.new()
	timer.name = "SpawnCheckTimer"
	timer.wait_time = 2.0  # Check every 2 seconds
	timer.timeout.connect(_on_spawn_check_timer_timeout)
	add_child(timer)
	
	# Get initial enemies
	_update_enemy_list()
	
	# Start checking for enemy count
	timer.start()

func _update_enemy_list() -> void:
	current_enemies.clear()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			current_enemies.append(enemy)

func _on_spawn_check_timer_timeout() -> void:
	_update_enemy_list()
	
	# If we have fewer than min_enemies, spawn more
	if current_enemies.size() < min_enemies:
		var num_to_spawn = min_enemies - current_enemies.size()
		_spawn_enemies(num_to_spawn)

func _spawn_enemies(count: int) -> void:
	if not enemy_scene:
		push_error("Enemy scene not set in spawn manager!")
		return
		
	# Get a reference point for spawning (use last enemy or center of screen)
	var spawn_point: Vector2
	if current_enemies.size() > 0:
		spawn_point = current_enemies[0].global_position
	else:
		# Use center of viewport if no enemies exist
		var viewport = get_viewport()
		spawn_point = viewport.get_visible_rect().get_center()
	
	# Spawn new enemies
	for i in range(count):
		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		
		# Calculate random position within spawn radius
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		enemy.global_position = spawn_point + offset 