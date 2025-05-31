extends RigidBody2D
var can_interact: bool = false
var is_open: bool = false
@export var chest_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("interactable")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		if is_open == false:
			is_open = true
			$AnimatedSprite2D.play("open")
			$AudioStreamPlayer2D.play()
			SceneManager.opened_chests.append(chest_name)
			print(SceneManager.opened_chests)
		else:
			is_open = false
			$AnimatedSprite2D.play("closed")

func set_interactable(value: bool) -> void:
	can_interact = value
