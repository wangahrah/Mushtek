extends Area2D

@export var speed: float = 100.0  # Slightly slower for better spread visibility
@export var damage: int = 10  # Same damage as fireball
@export var knockback_force: float = 300.0  # Force to push enemies back
@export var lifetime: float = 0.5  # Shorter lifetime for better spread visibility
var direction: Vector2 = Vector2.RIGHT
var time_alive: float = 0.0

func _ready() -> void:
	# Add to fungal push group
	add_to_group("fungal_push")
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the fungal push in its direction
	position += direction * speed * delta
	
	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("Fungal Push: Hit body ", body.name)
	if body.has_method("take_damage"):
		print("Fungal Push: Body has take_damage method")
		# Apply damage
		body.take_damage(damage)
		
		# Apply knockback
		if body is RigidBody2D:
			print("Fungal Push: Body is RigidBody2D, applying impulse")
			var knockback_direction = (body.global_position - global_position).normalized()
			body.apply_central_impulse(knockback_direction * knockback_force)
		elif body.has_method("apply_knockback"):
			print("Fungal Push: Body has apply_knockback method")
			var knockback_direction = (body.global_position - global_position).normalized()
			print("Fungal Push: Knockback direction: ", knockback_direction, " Force: ", knockback_force)
			body.apply_knockback(knockback_direction * knockback_force)
		else:
			print("Fungal Push: Body has neither RigidBody2D nor apply_knockback method")
	
	# Destroy the fungal push after hitting something
	queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	# Rotate the sprite to face the direction
	rotation = direction.angle() 
