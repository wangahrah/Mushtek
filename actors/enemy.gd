extends CharacterBody2D

var target: Node2D
var speed: float = 100.0  # Reduced speed for more realistic movement
var min_distance: float = 25.0
var buffer_distance: float = 10.0

# Patrol variables
var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var patrol_wait_time: float = 2.0
var patrol_timer: float = 0.0
var is_patrolling: bool = true

# Combat variables
@export var max_health: int = 30
var current_health: int = 30
var is_hit: bool = false
var hit_timer: float = 0.0
const HIT_DURATION: float = 0.2
@export var damage: int = 10
var damage_cooldown: float = 2.0
var damage_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	# Initialize patrol points around the enemy's starting position
	var start_pos = global_position
	patrol_points = [
		start_pos,
		start_pos + Vector2(100, 0),
		start_pos + Vector2(100, 100),
		start_pos + Vector2(0, 100)
	]
	
	# Add to enemy group for spell targeting
	add_to_group("enemy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_hit:
		hit_timer += delta
		if hit_timer >= HIT_DURATION:
			is_hit = false
			hit_timer = 0.0
			modulate = Color(1, 1, 1)
	
	if damage_timer > 0:
		damage_timer -= delta

	if target:
		# Player detected - chase behavior
		var distance_to_player: Vector2 = target.global_position - global_position
		var distance_length = distance_to_player.length()
		
		if distance_length > min_distance + buffer_distance:
			var direction_normal: Vector2 = distance_to_player.normalized()
			velocity = direction_normal * speed
		else:
			velocity = Vector2.ZERO
			# Try to damage player if in range
			if damage_timer <= 0 and target.has_method("take_damage"):
				target.take_damage(damage)
				damage_timer = damage_cooldown
	else:
		# Patrol behavior
		if is_patrolling:
			var target_point = patrol_points[current_patrol_index]
			var distance_to_point = global_position.distance_to(target_point)
			
			if distance_to_point < 10:
				patrol_timer += delta
				if patrol_timer >= patrol_wait_time:
					patrol_timer = 0
					current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
			else:
				var direction = (target_point - global_position).normalized()
				velocity = direction * speed * 0.5  # Slower speed while patrolling
		else:
			velocity = Vector2.ZERO
	
	# Update animation
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
		# Flip sprite based on movement direction
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	is_hit = true
	hit_timer = 0.0
	modulate = Color(1, 0.5, 0.5)
	
	if current_health <= 0:
		queue_free()

func _on_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("fireball") or area.is_in_group("lightning") or area.is_in_group("fungal_push"):
		take_damage(area.damage)

func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		is_patrolling = false

func _on_player_detect_area_2d_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		velocity = Vector2.ZERO
		is_patrolling = true
