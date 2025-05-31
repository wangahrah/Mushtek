extends Area2D
var bodies_on_top: int = 0
signal pressed
signal unpressed
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable") or body is Player:
		bodies_on_top += 1
		pressed.emit()
		$AnimatedSprite2D.play("pressed")
		print("entered")
		
func _on_body_exited(body: Node) -> void:
	bodies_on_top -= 1
	if bodies_on_top == 0:
		unpressed.emit()
		$AnimatedSprite2D.play("unpressed")
	print("exit")
