# Story of Technology (SOT) - Development Plan

## Overview
A dystopian tech future + mycology game where players craft equipment on-the-fly using collected natoms, with a focus on progression through crafting and exploration.

## Core Systems Development

### 1. Natom Resource System
- [ ] Create NatomResource class
  - [ ] Implement four tiers of natoms
  - [ ] Add natom collection mechanics
  - [ ] Implement energy drain system for equipped items
  - [ ] Create natom storage and management

### 2. Crafting System
- [ ] Create CraftingManager singleton
  - [ ] Implement blueprint scanning mechanics
  - [ ] Design recipe discovery system
  - [ ] Create on-the-fly crafting interface
  - [ ] Implement crafting costs and requirements

### 3. Equipment System
- [ ] Create EquipmentManager
  - [ ] Implement six equipment slots:
    - [ ] Hands (weapons)
    - [ ] Head
    - [ ] Eyes
    - [ ] Body
    - [ ] Feet
    - [ ] Accessory
  - [ ] Create equipment effects system
  - [ ] Design equipment templates for different tiers
  - [ ] Implement equipment switching mechanics

### 4. World Structure
- [ ] Design overmap system
  - [ ] Create world navigation
  - [ ] Implement area discovery
- [ ] Create dungeon system
  - [ ] Design procedural generation
  - [ ] Implement different dungeon types
- [ ] Design different biomes
  - [ ] Create unique natom collection areas
  - [ ] Implement special terrain types
- [ ] Design puzzle mechanics
  - [ ] Create puzzle templates
  - [ ] Implement puzzle rewards

### 5. Player Systems
- [ ] Enhance character controller
  - [ ] Implement movement mechanics
  - [ ] Add interaction system
- [ ] Create combat system
  - [ ] Design basic attacks
  - [ ] Implement special abilities
- [ ] Add scanning mechanics
  - [ ] Create blueprint discovery
  - [ ] Implement resource scanning
- [ ] Design progression system
  - [ ] Create experience/leveling
  - [ ] Implement skill unlocks

### 6. UI/UX
- [ ] Design crafting interface
  - [ ] Create recipe display
  - [ ] Implement crafting controls
- [ ] Create natom management UI
  - [ ] Display natom quantities
  - [ ] Show energy drain rates
- [ ] Design equipment management screen
  - [ ] Create slot management
  - [ ] Implement equipment preview
- [ ] Add blueprint discovery interface
  - [ ] Create blueprint collection display
  - [ ] Implement scanning interface

### 7. Technical Improvements
- [ ] Implement save/load system
  - [ ] Create save data structure
  - [ ] Add auto-save functionality
- [ ] Enhance scene management
  - [ ] Implement proper scene transitions
  - [ ] Add scene preloading
- [ ] Create resource management system
  - [ ] Implement resource caching
  - [ ] Add memory management
- [ ] Set up signal system
  - [ ] Create game event system
  - [ ] Implement UI feedback

### 8. Content Development
- [ ] Create initial blueprints
  - [ ] Design basic equipment recipes
  - [ ] Create special item blueprints
- [ ] Design equipment sets
  - [ ] Create tier 1 equipment
  - [ ] Design progression paths
- [ ] Create initial areas
  - [ ] Design starting zone
  - [ ] Create tutorial area
- [ ] Design puzzle templates
  - [ ] Create basic puzzle types
  - [ ] Implement puzzle rewards

## Best Practices
- [ ] Use Godot's built-in signals for system communication
- [ ] Implement proper resource management
- [ ] Use autoload singletons for global systems
- [ ] Follow node-based architecture
- [ ] Implement proper scene instancing
- [ ] Use proper state management
- [ ] Utilize Godot's physics system
- [ ] Follow GDScript coding standards

## Next Immediate Steps
1. Set up NatomResource system
2. Create basic equipment framework
3. Implement crafting manager
4. Design basic UI framework

## Notes
- Focus on modular design for easy expansion
- Maintain performance with proper resource management
- Ensure smooth gameplay experience
- Keep UI intuitive and responsive 