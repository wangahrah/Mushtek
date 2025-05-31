extends CharacterBody2D
var dialogue_lines: Array[String] = ["I'm a dog","I'm a cat","I'M NOT A MONSTER"]
var can_interact: bool = false
var dialogue_index: int = 0
var target: Node2D
var speed: float = 3000.0  # Speed in pixels per second
var min_distance: float = 25.0  # Stop when within this distance
var buffer_distance: float = 10.0  # Additional buffer to prevent sticking

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("interactable")

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
		
	if can_interact == false:
		$CanvasLayer.visible = false
	if Input.is_action_just_pressed("interact") and can_interact:
		if dialogue_index < dialogue_lines.size():
			$AudioStreamPlayer2D.play()
			$CanvasLayer.visible = true
			$CanvasLayer/Label.text = (dialogue_lines[dialogue_index])
			dialogue_index += 1
		else:
			dialogue_index = 0;
			$CanvasLayer.visible = false
	move_and_slide()

func set_interactable(value: bool) -> void:
	can_interact = value

func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_player_detect_area_2d_body_exited(body: Node2D) -> void:
	if body == target:  # Only clear target if it's the same body that entered
		target = null
		velocity = Vector2.ZERO
