extends Area2D

@export var speed: float = 50.0  # Reduced from 400 to 150
@export var damage: int = 10
@export var lifetime: float = 5.0  # 5 seconds lifetime
var direction: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0

func _ready() -> void:
	# Add to fireball group
	add_to_group("fireball")
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the fireball in its direction
	position += direction * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is a player
	if body is Player:
		SceneManager.health_manager.take_damage(damage)
	# Check if the body is an enemy
	elif body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroy the fireball after hitting something
	queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate the sprite to face the direction
	rotation = direction.angle() 
