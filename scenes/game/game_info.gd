extends Panel
class_name GameInfo

@export var grid : GameGrid
@export var mines_left_label : Label
@export var clock_timer: Timer
@export var new_record_text: RichTextLabel

@export var menu_container : Control

var _current_game_preset : GamePreset
var _mines_count : int

func _ready() -> void:
	grid.cell_switched.connect(_on_cell_switched)
	grid.grid_generated.connect(_on_grid_generated)
	grid.losed.connect(_on_lose)
	grid.winned.connect(_on_win)
	grid.cell_opened.connect(_on_cell_opened)

func _on_lose(mines_left:int) -> void:
	clock_timer.stop()
	mines_left_label.text = "Lose! {0}%".format([int(100.0 - float(mines_left) / float(grid._mines_coords.size()) * 100.0)])

func _on_win()->void:
	clock_timer.stop()
	mines_left_label.text = "Win!"
	new_record_text.visible = GameManager.register_win(_current_game_preset, clock_timer._total_seconds)

func _on_grid_generated(preset:GamePreset, mines_coords:Array[Vector2i])->void:
	_update_mines_left_label(mines_coords.size())
	clock_timer.reset()
	_current_game_preset = preset
	_mines_count = mines_coords.size()
	new_record_text.hide()

func _on_cell_opened(_index:Vector2i)->void:
	if clock_timer.is_stopped():
		clock_timer.start()

func _on_cell_switched(_index:Vector2i) -> void:
	var fake_mines_left := grid.get_fake_mines_left_count()
	var real_mines_left := grid.get_real_mines_left_count()
	print("Mines: fake: {0}, real: {1}".format([fake_mines_left, real_mines_left]))
	_update_mines_left_label(fake_mines_left)
	if clock_timer.is_stopped():
		clock_timer.start()

func _update_mines_left_label(mines: int)->void:
	mines_left_label.text = str(mines)

func _on_menu_btn_pressed() -> void:
	get_parent().hide()
	menu_container.show()
