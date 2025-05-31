extends StaticBody2D
var dialogue_lines: Array[String] = ["Don't hurt me!","I'm just a cute butterfly","I'm not evil like sheep"]
var can_interact: bool = false
var dialogue_index: int = 0

# Health variables
@export var max_health: int = 30
var current_health: int = 30
var is_hit: bool = false
var hit_timer: float = 0.0
const HIT_DURATION: float = 0.2  # How long the hit effect lasts

# Bioatoms drop variables
const BIOATOMS_SCENE = preload("res://scenes/bioatoms/bioatoms.tscn")
const MIN_BIOATOMS: int = 3
const MAX_BIOATOMS: int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	add_to_group("interactable")
	# Connect the area_entered signal
#	$CollisionShape2D.area_entered.connect(_on_hit_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_interact == false:
		$CanvasLayer.visible = false
	if Input.is_action_just_pressed("interact") and can_interact:
		print("interact")
		if dialogue_index < dialogue_lines.size():
			print("run dialog")
			$CanvasLayer.visible = true
			$CanvasLayer/Label.text = (dialogue_lines[dialogue_index])
			dialogue_index += 1
		else:
			dialogue_index = 0;
			$CanvasLayer.visible = false
	
	# Handle hit effect
	if is_hit:
		hit_timer += delta
		if hit_timer >= HIT_DURATION:
			is_hit = false
			hit_timer = 0.0
			modulate = Color(1, 1, 1)  # Reset color

func set_interactable(value: bool) -> void:
	can_interact = value

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
