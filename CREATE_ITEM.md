# Creating Equipment Items

This guide explains how to create new equipment items that will automatically be loaded into the equipment system.

## File Location

All equipment items should be placed in:
```
res://resources/equipment/
```

## File Naming

Name your item files with the following pattern:
```
[item_name]_[slot]_t[tier].tres
```

For example:
- `leather_cap_head_t1.tres` - A tier 1 leather cap for the head slot
- `iron_boots_feet_t2.tres` - A tier 2 pair of iron boots for the feet slot

## Item Properties

Each item is a resource file with the following properties:

```gdscript
# Basic properties
item_name: String        # Display name of the item
description: String      # Item description shown in UI
slot_type: int          # Equipment slot (0=HEAD, 1=HANDS, 2=BODY, 3=FEET)
is_unlocked: bool       # Whether the item is available by default
tier: int               # Item tier (1-5)

# Visual properties
icon: Texture2D         # Item icon shown in UI (use res://assets/Items/Potion/Heart.png)
model_scene: PackedScene # Optional: 3D model for the item

# Gameplay properties
stat_changes: Dictionary # Stats modified when equipped
requirements: Dictionary # Requirements to equip the item
```

## Example Item

Here's an example of a tier 1 leather cap:

```gdscript
[gd_resource type="Resource" script_class="EquipmentItem" load_steps=3 format=3]

[ext_resource type="Script" path="res://objects/equipment_item.gd" id="1_2k4m3"]
[ext_resource type="Texture2D" path="res://assets/Items/Potion/Heart.png" id="2_8dubc"]

[resource]
script = ExtResource("1_2k4m3")
item_name = "Leather Cap"
description = "A sturdy leather cap. Offers better protection than a basic cloth cap."
slot_type = 0  # HEAD slot
tier = 1
is_unlocked = true
icon = ExtResource("2_8dubc")
stat_changes = {
    "defense": 3,
    "speed": -1
}
requirements = {}
```

## Slot Types

Use these values for `slot_type`:
- `0`: Head slot
- `1`: Hands slot
- `2`: Body slot
- `3`: Feet slot

## Stat Changes

The `stat_changes` dictionary can modify any of these stats:
- `health`: Maximum health points
- `defense`: Damage reduction
- `speed`: Movement speed
- `attack`: Attack damage

Example:
```gdscript
stat_changes = {
    "defense": 3,    # +3 defense
    "speed": -1      # -1 speed
}
```

## Requirements

The `requirements` dictionary can specify requirements to equip the item:
```gdscript
requirements = {
    "level": 5,      # Requires level 5
    "strength": 10   # Requires 10 strength
}
```

## Tier System

Items are organized into 5 tiers:
- Tier 1: Basic items
- Tier 2: 50% better than tier 1
- Tier 3: 100% better than tier 1
- Tier 4: 150% better than tier 1
- Tier 5: 200% better than tier 1

## Testing Your Item

1. Create your `.tres` file in the equipment directory
2. Run the game
3. Open the equipment UI (default key: Q)
4. Select the appropriate slot
5. Your item should appear in the list if its tier is unlocked

## Debug Tips

If your item doesn't appear:
1. Check the debug output in the console
2. Verify the file is in the correct directory
3. Confirm the slot_type matches the intended slot
4. Make sure the tier is unlocked (tier 1 is unlocked by default)
5. Check that is_unlocked is set to true
6. Ensure you're using the correct icon path: `res://assets/Items/Potion/Heart.png`

## Best Practices

1. Use descriptive names that indicate the slot and tier
2. Provide clear descriptions of item effects
3. Balance stat changes appropriately for the tier
4. Always use `res://assets/Items/Potion/Heart.png` as the icon until proper armor icons are added
5. Test items thoroughly before adding them to the game 