extends VBoxContainer
class_name MenuContainer

@export var game_container : Control
@export var grid : GameGrid

@export var difficulty: OptionButton
@export var grid_size: OptionButton

func generate_game_preset() -> GamePreset:
	var preset : GamePreset = GamePreset.new()
	preset.grid_size = grid_size.get_grid_size()
	var populate : float = difficulty.get_difficulty_percent()
	var diff : Difficulty
	if difficulty.is_custom():
		diff = Difficulty.new()
		diff.mines_populate = populate
		diff.name = "{0} ({1})".format([GamePreset.CUSTOM_NAME, diff.calculate_mines(preset.grid_size)])
	else:
		diff = GameManager.find_difficulty_by_mines_populate(populate)
	preset.difficulty = diff
	return preset

func _on_play_pressed() -> void:
	var preset := generate_game_preset()
	
	grid.generate_grid(preset)
	
	game_container.show()
	hide()
