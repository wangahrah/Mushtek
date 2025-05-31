extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('Hello World!')
	rotation_degrees = 45
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees += 1
	position.x -= 1
