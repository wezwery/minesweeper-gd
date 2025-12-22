extends Resource
class_name Difficulty

@export var name : String
@export_range(0.0, 100.0, 0.1) var mines_populate : float

func calculate_mines(grid_size:Vector2i)->int:
	return clamp(grid_size.x * grid_size.y * (mines_populate / 100.0), 1, grid_size.x * grid_size.y - 1)
