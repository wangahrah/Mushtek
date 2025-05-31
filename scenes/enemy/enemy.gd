extends CharacterBody2D

var target: Node2D
var speed: float = 3000.0  # Speed in pixels per second
var min_distance: float = 25.0  # Stop when within this distance
var buffer_distance: float = 10.0  # Additional buffer to prevent sticking

# Health variables
@export var max_health: int = 30
var current_health: int = 30
var is_hit: bool = false
var hit_timer: float = 0.0
const HIT_DURATION: float = 0.2  # How long the hit effect lasts

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		var distance_to_player: Vector2 = target.global_position - global_position
		var distance_length = distance_to_player.length()
		
		if distance_length > min_distance + buffer_distance:
			var direction_normal: Vector2 = distance_to_player.normalized()
			# Slow down as we get closer to the target
			var speed_multiplier = min(1.0, (distance_length - min_distance) / 100.0)
			velocity = direction_normal * speed * speed_multiplier * delta
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
		
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
		
	move_and_slide()
	
	if is_hit:
		hit_timer += delta
	if hit_timer >= HIT_DURATION:
			is_hit = false
			hit_timer = 0.0
			modulate = Color(1, 1, 1)  # Reset color

func take_damage(amount: int) -> void:
	current_health -= amount
	is_hit = true
	hit_timer = 0.0
	modulate = Color(1, 0.5, 0.5)  # Red tint when hit
	
	if current_health <= 0:
		queue_free()  # Remove the creature when health reaches 0

func _on_hit_area_entered(area: Area2D) -> void:
	# Check if the area is a fireball
	if area.is_in_group("fireball"):
		take_damage(area.damage)
		print("fireball")



func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_player_detect_area_2d_body_exited(body: Node2D) -> void:
	if body == target:  # Only clear target if it's the same body that entered
		target = null
		velocity = Vector2.ZERO
