extends Area2D

@export var health: int = 10.0  # Reduced from 400 to 150
 
func _ready() -> void:
	# Add to fireball group
	add_to_group("food")
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is a player
	if body is Player:
		body.heal(health)
	
	# Destroy the fireball after hitting something
	queue_free()
