extends CharacterBody2D

var speed: float = 100.0  # Reduced speed for more realistic movement
var base_speed: float = 100.0  # Store the base speed
var is_slowed: bool = false
var slowdown_timer: float = 0.0
const SLOWDOWN_DURATION: float = 0.5
const SLOWDOWN_MULTIPLIER: float = 0.5  # 50% slowdown

# Random movement variables
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var wander_time: float = 2.0  # Time before changing direction
var min_wander_time: float = 1.0
var max_wander_time: float = 3.0

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
	# Initialize random direction
	randomize()
	wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(min_wander_time, max_wander_time)
	
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
		
	# Handle slowdown
	if is_slowed:
		slowdown_timer += delta
		if slowdown_timer >= SLOWDOWN_DURATION:
			is_slowed = false
			slowdown_timer = 0.0
			speed = base_speed
			print("Enemy: Slowdown ended, speed restored to: ", speed)

	# Random wandering behavior
	wander_timer += delta
	if wander_timer >= wander_time:
		wander_timer = 0
		# Generate new random direction
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_time = randf_range(min_wander_time, max_wander_time)
	
	velocity = wander_direction * speed * 0.5  # Slower speed while wandering
	
	# Update animation
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
		# Flip sprite based on movement direction
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()
	
	# Handle collisions and bounce off walls
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		wander_direction = reflect.normalized()
		# Add some randomness to the bounce
		wander_direction = wander_direction.rotated(randf_range(-PI/4, PI/4))
		wander_timer = 0  # Reset timer to allow for new direction change

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

func apply_knockback(force: Vector2) -> void:
	print("Enemy: Received knockback force: ", force)
	velocity = force
	print("Enemy: New velocity set to: ", velocity)
	move_and_slide()
	print("Enemy: After move_and_slide, velocity is: ", velocity)
	
	# Apply slowdown effect
	is_slowed = true
	slowdown_timer = 0.0
	speed = base_speed * SLOWDOWN_MULTIPLIER
	print("Enemy: Applied slowdown, new speed: ", speed)
