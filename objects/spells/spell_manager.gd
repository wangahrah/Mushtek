extends Node
class_name SpellManager

signal spell_changed(spell: BaseSpell)
signal spell_cast(spell: BaseSpell)

# Spell selection
var available_spells: Array[BaseSpell] = []
var current_spell_index: int = 0
var current_spell: BaseSpell

# Input handling
var scroll_sensitivity: float = 0.1
var last_scroll_value: float = 0.0

func _ready() -> void:
	# Initialize with empty array
	available_spells = []
	current_spell = null

func _process(_delta: float) -> void:
	_handle_spell_selection()
	_handle_spell_casting()

func _handle_spell_selection() -> void:
	var scroll_value = Input.get_axis("scroll_up", "scroll_down")
	if scroll_value != 0 and available_spells.size() > 0:
		# Change spell based on scroll direction
		current_spell_index = (current_spell_index + int(scroll_value)) % available_spells.size()
		if current_spell_index < 0:
			current_spell_index = available_spells.size() - 1
		
		current_spell = available_spells[current_spell_index]
		spell_changed.emit(current_spell)

func _handle_spell_casting() -> void:
	if current_spell and Input.is_action_just_pressed("cast_spell"):
		if current_spell.can_cast():
			var parent = get_parent()
			if parent is Node2D:
				current_spell.cast(parent, parent.get_global_mouse_position())
				current_spell.consume_natoms()
				current_spell.start_cooldown()
				spell_cast.emit(current_spell)

func add_spell(spell: BaseSpell) -> void:
	# Add spell to scene tree
	add_child(spell)
	available_spells.append(spell)
	if current_spell == null:
		current_spell = spell
		current_spell_index = 0
		spell_changed.emit(current_spell)

func remove_spell(spell: BaseSpell) -> void:
	var index = available_spells.find(spell)
	if index != -1:
		# Remove spell from scene tree
		remove_child(spell)
		available_spells.remove_at(index)
		if current_spell == spell:
			if available_spells.size() > 0:
				current_spell_index = 0
				current_spell = available_spells[0]
				spell_changed.emit(current_spell)
			else:
				current_spell = null
				current_spell_index = 0

func get_current_spell() -> BaseSpell:
	return current_spell 
