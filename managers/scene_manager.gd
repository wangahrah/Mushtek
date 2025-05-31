extends Node2D
@export var player_spawn_position: Vector2

var opened_chests: Array[String] = []
var max_health: int = 100
var current_health: int = 100
var inventory_manager: Node
var natom_manager: Node
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
	
	# Connect to inventory changes
	inventory_manager.inventory_changed.connect(_on_inventory_changed)
	
	# Connect to natom signals
	natom_manager.natom_collected.connect(_on_natom_collected)
	natom_manager.energy_drained.connect(_on_energy_drained)
	natom_manager.energy_depleted.connect(_on_energy_depleted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_inventory_changed(item_name: String, quantity: int) -> void:
	print("Inventory updated: %s - Quantity: %d" % [item_name, quantity])
	# Update player's inventory display if player exists
	if player:
		player.update_inventory()

func _on_natom_collected(tier: NatomResource.Tier, amount: int) -> void:
	print("Collected %d %s natoms" % [amount, natom_manager.get_natom_resource(tier).get_tier_name()])
	if player:
		player.update_inventory()

func _on_energy_drained(tier: NatomResource.Tier, amount: float) -> void:
	print("Energy drained from %s: %.2f" % [natom_manager.get_natom_resource(tier).get_tier_name(), amount])
	if player:
		player.update_energy_display()

func _on_energy_depleted(tier: NatomResource.Tier) -> void:
	print("Energy depleted for %s" % natom_manager.get_natom_resource(tier).get_tier_name())
	if player:
		player.on_energy_depleted(tier)

func add_natoms(tier: NatomResource.Tier, quantity: int) -> void:
	inventory_manager.add_item("natom_tier_" + str(tier), quantity)

func set_player(p: Player) -> void:
	player = p
