extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_floorbutton_pressed() -> void:
	$AnimatedSprite2D.play("open")
	$CollisionShape2D.set_deferred("disabled", true)
	print("door open")


func _on_floorbutton_unpressed() -> void:
	$AnimatedSprite2D.play("closed")
	$CollisionShape2D.set_deferred("disabled", false)
	print("door close")
