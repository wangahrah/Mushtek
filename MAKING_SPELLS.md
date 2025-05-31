# Creating New Spells in Mushtek

This document provides guidance for implementing new spells in the Mushtek spell system. The system is designed to be modular and extensible, allowing for easy addition of new spells with different behaviors.

## Spell System Architecture

The spell system consists of three main components:

1. `BaseSpell` (objects/spells/base_spell.gd)
   - Abstract base class that all spells inherit from
   - Handles common functionality like cooldowns and natom costs
   - Provides the interface that all spells must implement

2. `SpellManager` (objects/spells/spell_manager.gd)
   - Manages spell selection and casting
   - Handles input for spell selection (scroll wheel) and casting
   - Maintains the list of available spells

3. Individual Spell Implementations
   - Inherit from `BaseSpell`
   - Implement specific spell behavior
   - Define spell properties and effects

## Creating a New Spell

To create a new spell, follow these steps:

1. Create a new script that inherits from `BaseSpell`:

```gdscript
extends BaseSpell
class_name YourSpellName

# Spell-specific properties
@export var your_property: Type = default_value

func _init() -> void:
    # Set basic spell properties
    spell_name = "Your Spell Name"
    natom_cost = 10  # Cost in natoms
    cooldown = 1.0   # Cooldown in seconds
    cast_range = 300.0  # Maximum cast range

func cast(caster: Node2D, target_position: Vector2) -> void:
    # Implement your spell's behavior here
    # caster: The node casting the spell (usually the player)
    # target_position: Where the spell is being cast (usually mouse position)
    pass
```

2. Implement the required methods:
   - `_init()`: Set up basic spell properties
   - `cast()`: Implement the spell's behavior

3. Add the spell to the player's spell manager in `oldman.gd`:

```gdscript
func _initialize_spells() -> void:
    # Add your new spell
    var your_spell = YourSpellName.new()
    spell_manager.add_spell(your_spell)
```

## Spell Properties

The `BaseSpell` class provides these properties that you can customize:

- `spell_name`: Name of the spell
- `spell_icon`: Texture for the spell's icon
- `natom_cost`: Cost in natoms to cast
- `cooldown`: Time between casts
- `cast_range`: Maximum casting range

## Example: Fireball Spell

Here's an example of the Fireball spell implementation:

```gdscript
extends BaseSpell
class_name FireballSpell

@export var fireball_scene: PackedScene
@export var spawn_distance: float = 30.0

func _init() -> void:
    spell_name = "Fireball"
    natom_cost = 5
    cooldown = 0.5
    cast_range = 300.0

func cast(caster: Node2D, target_position: Vector2) -> void:
    if not fireball_scene:
        push_error("Fireball scene not set in FireballSpell!")
        return
        
    var fireball = fireball_scene.instantiate()
    caster.get_parent().add_child(fireball)
    
    var direction = (target_position - caster.global_position).normalized()
    var spawn_offset = Vector2(spawn_distance, 0)
    spawn_offset = spawn_offset.rotated(direction.angle())
    fireball.global_position = caster.global_position + spawn_offset
    
    fireball.set_direction(direction)
```

## Best Practices

1. **Scene Management**
   - If your spell creates scene instances, make sure to add them to the scene tree
   - Consider using object pooling for frequently cast spells

2. **Resource Management**
   - Preload scene resources in `_init()` if they're always needed
   - Use `@export` for configurable properties

3. **Error Handling**
   - Check for required resources before casting
   - Use `push_error()` for missing dependencies

4. **Performance**
   - Keep spell logic efficient
   - Clean up any resources when the spell is done

## Spell Types

The system supports various types of spells:

1. **Projectile Spells** (like Fireball)
   - Create and launch projectiles
   - Handle collision and damage

2. **Area Effect Spells**
   - Create effects in a target area
   - Apply effects to all entities in range

3. **Buff/Debuff Spells**
   - Apply status effects to targets
   - Modify entity properties

4. **Summoning Spells**
   - Create temporary entities
   - Control summoned entities

## Testing New Spells

1. Add the spell to the player's spell manager
2. Test the spell's behavior:
   - Casting mechanics
   - Cooldown system
   - Resource costs
   - Visual effects
   - Collision detection

## Common Issues

1. **Spell not casting**
   - Check if the spell is added to the scene tree
   - Verify cooldown and natom cost settings
   - Ensure the spell is properly added to the spell manager

2. **Resources not loading**
   - Verify resource paths
   - Check if resources are properly exported
   - Ensure resources are preloaded if needed

3. **Performance issues**
   - Check for resource leaks
   - Verify cleanup of temporary objects
   - Monitor scene tree for orphaned nodes 