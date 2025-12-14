extends VBoxContainer
class_name MenuContainer

@export var game_container : Control
@export var grid : GameGrid

@export var difficulty: OptionButton
@export var grid_size: OptionButton

func _on_play_pressed() -> void:
	var diff : float = difficulty.get_difficulty_percent() / 100.0
	var g_size : Vector2i = grid_size.get_grid_size()
	var mines : int = clamp(g_size.x * g_size.y * diff, 1, g_size.x * g_size.y - 1)
	
	grid.generate_grid(g_size.x, g_size.y, mines)
	
	game_container.show()
	hide()
