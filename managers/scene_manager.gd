extends Node2D
@export var player_spawn_position: Vector2

var opened_chests: Array[String] = []
var inventory_manager: Node
var natom_manager: Node
var health_manager: Node
var ui_manager: Node
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize inventory manager
	inventory_manager = Node.new()
	inventory_manager.set_script(load("res://managers/inventory_manager.gd"))
	add_child(inventory_manager)
	
	# Initialize natom manager
	natom_manager = Node.new()
	natom_manager.set_script(load("res://objects/natom_manager.gd"))
	add_child(natom_manager)
	
	# Initialize health manager
	health_manager = Node.new()
	health_manager.set_script(load("res://managers/health_manager.gd"))
	add_child(health_manager)
	
	# Initialize UI manager
	var ui_scene = load("res://scenes/ui.tscn")
	ui_manager = ui_scene.instantiate()
	add_child(ui_manager)
	
	# Connect to inventory changes
	inventory_manager.inventory_changed.connect(_on_inventory_changed)
	
	# Connect to natom signals
	natom_manager.natom_collected.connect(_on_natom_collected)
	natom_manager.energy_drained.connect(_on_energy_drained)
	natom_manager.energy_depleted.connect(_on_energy_depleted)
	
	# Connect to health signals
	health_manager.health_changed.connect(_on_health_changed)
	health_manager.player_died.connect(_on_player_died)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_inventory_changed(item_name: String, quantity: int) -> void:
	print("Inventory updated: %s - Quantity: %d" % [item_name, quantity])

func _on_natom_collected(tier: NatomResource.Tier, amount: int) -> void:
	print("Collected %d %s natoms" % [amount, natom_manager.get_natom_resource(tier).get_tier_name()])

func _on_energy_drained(tier: NatomResource.Tier, amount: float) -> void:
	print("Energy drained from %s: %.2f" % [natom_manager.get_natom_resource(tier).get_tier_name(), amount])

func _on_energy_depleted(tier: NatomResource.Tier) -> void:
	print("Energy depleted for %s" % natom_manager.get_natom_resource(tier).get_tier_name())

func _on_health_changed(new_health: int) -> void:
	print("Health changed to: %d" % new_health)

func _on_player_died() -> void:
	print("Player died!")

func add_natoms(tier: NatomResource.Tier, quantity: int) -> void:
	inventory_manager.add_item("natom_tier_" + str(tier), quantity)

func set_player(p: Player) -> void:
	player = p
