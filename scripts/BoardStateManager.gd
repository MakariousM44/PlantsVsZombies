extends Node

# tile pixel size
const TILE_SIZE = Vector2(32, 24)

# world size
const TOTAL_ROWS = 11
const TOTAL_COLS = 16

# playable start area
const GRID_OFFSET = Vector2i(2, 3)

# playable zones cols (inclusive) - 12 cols total, 4 plants, 4 blocked, 4 zombies
const PLANT_ZONE_START = 2
const PLANT_ZONE_END = 5
const COMBAT_ZONE_START = 6
const COMBAT_ZONE_END = 9
const ZOMBIE_ZONE_START = 10
const ZOMBIE_ZONE_END = 13

# playable zones rows (inclusive) - 6 rows total
const PLAYABLE_ROWS_START = 3
const PLAYABLE_ROWS_END = 8

var grid: Dictionary = {}

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(world_pos / TILE_SIZE)

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) * TILE_SIZE + TILE_SIZE / 2

func is_cell_occupied(cell: Vector2i) -> bool:
	return grid.has(cell)

func is_plant_zone(cell: Vector2i) -> bool:
	return cell.x >= PLANT_ZONE_START and cell.x <= PLANT_ZONE_END and cell.y >= PLAYABLE_ROWS_START and cell.y <= PLAYABLE_ROWS_END

func is_zombie_zone(cell: Vector2i) -> bool:
	return cell.x >= ZOMBIE_ZONE_START and cell.x <= ZOMBIE_ZONE_END and cell.y >= PLAYABLE_ROWS_START and cell.y <= PLAYABLE_ROWS_END

func is_combat_zone(cell: Vector2i) -> bool:
	return cell.x >= COMBAT_ZONE_START and cell.x <= COMBAT_ZONE_END and cell.y >= PLAYABLE_ROWS_START and cell.y <= PLAYABLE_ROWS_END

func is_valid_plant_placement(cell: Vector2i) -> bool:
	return is_plant_zone(cell) and not is_cell_occupied(cell)

func is_valid_zombie_placement(cell: Vector2i) -> bool:
	return is_zombie_zone(cell) and not is_cell_occupied(cell)
