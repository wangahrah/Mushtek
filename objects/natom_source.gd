extends Node2D

@export var natom_tier: NatomResource.Tier = NatomResource.Tier.TIER_1
@export var collection_rate: float = 10.0
@export var max_natoms: int = 1000
@export var respawn_time: float = 30.0

var current_natoms: int = 0
var is_collecting: bool = false
var collection_timer: float = 0.0
var respawn_timer: float = 0.0
var is_depleted: bool = false

# Visual properties
var base_color: Color = Color(1, 1, 1, 1)
var tier_colors: Dictionary = {
	NatomResource.Tier.TIER_1: Color(0.5, 0.8, 1, 1),    # Light blue
	NatomResource.Tier.TIER_2: Color(0.8, 0.5, 1, 1),    # Purple
	NatomResource.Tier.TIER_3: Color(1, 0.8, 0.5, 1),    # Orange
	NatomResource.Tier.TIER_4: Color(1, 0.5, 0.5, 1)     # Red
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $Particles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D

func _ready() -> void:
	current_natoms = max_natoms
	add_to_group("natom_source")
	print("DEBUG: Natom source initialized with ", max_natoms, " natoms")
	print("DEBUG: Natom source collision settings:")
	print("  - Layer: ", area.collision_layer)
	print("  - Mask: ", area.collision_mask)
	
	# Set initial color based on tier
	_update_visuals()
	
	# Connect area signals
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	print("DEBUG: Natom source signals connected")

func _process(delta: float) -> void:
	if is_collecting and not is_depleted:
		collection_timer += delta
		if collection_timer >= 0.1:  # Collect every 0.1 seconds instead of 1.0
			collection_timer = 0.0
			print("DEBUG: Collection timer triggered")
			_collect_natoms()
	
	if is_depleted:
		respawn_timer += delta
		if respawn_timer >= respawn_time:
			_respawn()
		else:
			print("DEBUG: Natom source respawning in %.1f seconds" % (respawn_time - respawn_timer))

func _update_visuals() -> void:
	# Update sprite color based on tier
	sprite.modulate = tier_colors.get(natom_tier, base_color)
	
	# Update particle color
	particles.color = tier_colors.get(natom_tier, base_color)
	
	# Update particle properties based on tier
	match natom_tier:
		NatomResource.Tier.TIER_1:
			particles.amount = 20
			particles.initial_velocity_min = 20.0
			particles.initial_velocity_max = 40.0
		NatomResource.Tier.TIER_2:
			particles.amount = 30
			particles.initial_velocity_min = 30.0
			particles.initial_velocity_max = 50.0
		NatomResource.Tier.TIER_3:
			particles.amount = 40
			particles.initial_velocity_min = 40.0
			particles.initial_velocity_max = 60.0
		NatomResource.Tier.TIER_4:
			particles.amount = 50
			particles.initial_velocity_min = 50.0
			particles.initial_velocity_max = 70.0

func start_collection(collector: Node) -> void:
	print("DEBUG: Starting collection from source")
	if not is_depleted:
		is_collecting = true
		collection_timer = 0.0
		# Start collection animation
		animation_player.play("collect")
		print("DEBUG: Collection started successfully")
	else:
		print("DEBUG: Cannot collect - source is depleted")

func stop_collection() -> void:
	print("DEBUG: Stopping collection")
	is_collecting = false
	# Stop collection animation
	animation_player.stop()

func _collect_natoms() -> void:
	if current_natoms > 0:
		var amount = min(int(collection_rate), current_natoms)
		current_natoms -= amount
		print("DEBUG: Collected ", amount, " natoms. Remaining: ", current_natoms, "/", max_natoms)
		
		# Distribute natoms across all tiers up to current tier
		match natom_tier:
			NatomResource.Tier.TIER_4:
				SceneManager.add_natoms(NatomResource.Tier.TIER_4, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_3, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_2, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_1, amount)
			NatomResource.Tier.TIER_3:
				SceneManager.add_natoms(NatomResource.Tier.TIER_3, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_2, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_1, amount)
			NatomResource.Tier.TIER_2:
				SceneManager.add_natoms(NatomResource.Tier.TIER_2, amount)
				SceneManager.add_natoms(NatomResource.Tier.TIER_1, amount)
			NatomResource.Tier.TIER_1:
				SceneManager.add_natoms(NatomResource.Tier.TIER_1, amount)
		
		# Emit particles
		particles.emitting = true
		
		if current_natoms <= 0:
			_deplete()
	else:
		print("DEBUG: No natoms left to collect")

func _deplete() -> void:
	is_depleted = true
	is_collecting = false
	respawn_timer = 0.0
	print("DEBUG: Natom source depleted! Respawn in ", respawn_time, " seconds")
	# Add visual feedback for depletion
	modulate = Color(0.5, 0.5, 0.5, 0.5)
	animation_player.play("deplete")

func _respawn() -> void:
	is_depleted = false
	current_natoms = max_natoms
	print("DEBUG: Natom source respawned! Now has ", max_natoms, " natoms")
	# Reset visual feedback
	modulate = Color(1, 1, 1, 1)
	animation_player.play("respawn")

func _on_body_entered(body: Node2D) -> void:
	print("DEBUG: Body entered natom source area: ", body.name)
	print("DEBUG: Body collision layer: ", body.collision_layer if body.has_method("get_collision_layer") else "N/A")
	if body is Player:
		print("DEBUG: Player entered natom source area")
		start_collection(body)

func _on_body_exited(body: Node2D) -> void:
	print("DEBUG: Body exited natom source area: ", body.name)
	if body is Player:
		print("DEBUG: Player exited natom source area")
		stop_collection() 
