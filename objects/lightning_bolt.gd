extends Area2D

@export var speed: float = 800.0  # Very fast projectile
@export var damage: int = 20  # Base damage
@export var lifetime: float = 0.5  # Short lifetime since it's fast
var direction: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0

# Chain properties
var chain_count: int = 3
var chain_range: float = 100.0
var chain_damage_reduction: float = 0.7
var hit_enemies: Array = []  # Track enemies hit for chaining

func _ready() -> void:
	# Add to lightning group
	add_to_group("lightning")
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the lightning bolt in its direction
	position += direction * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not hit_enemies.has(body):
		# Apply damage
		body.take_damage(damage)
		hit_enemies.append(body)
		
		# Try to chain to another enemy
		if hit_enemies.size() < chain_count:
			var next_target = find_next_chain_target()
			if next_target:
				chain_to_target(next_target)
			else:
				queue_free()
		else:
			queue_free()

func find_next_chain_target() -> Node2D:
	var potential_targets = get_tree().get_nodes_in_group("enemy")
	var closest_target = null
	var closest_distance = chain_range
	
	for target in potential_targets:
		if not hit_enemies.has(target):
			var distance = global_position.distance_to(target.global_position)
			if distance < closest_distance:
				closest_target = target
				closest_distance = distance
	
	return closest_target

func chain_to_target(target: Node2D) -> void:
	# Create a new lightning bolt for the chain
	var chain_bolt = duplicate()
	get_parent().add_child(chain_bolt)
	
	# Set up chain bolt properties
	chain_bolt.hit_enemies = hit_enemies.duplicate()
	chain_bolt.damage = int(damage * chain_damage_reduction)
	chain_bolt.global_position = global_position
	
	# Calculate direction to target
	var chain_direction = (target.global_position - global_position).normalized()
	chain_bolt.set_direction(chain_direction)
	
	# Remove the original bolt
	queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate the sprite to face the direction
	rotation = direction.angle() 
