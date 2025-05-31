extends Node

signal health_changed(new_health: int)
signal player_died

var max_health: int = 100
var current_health: int = 100

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health)

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health 