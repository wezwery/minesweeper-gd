extends TileMapLayer
class_name GameGrid

signal cell_switched(index : Vector2i)
signal grid_generated(size : Vector2i, mines_coords: Array[Vector2i])
signal losed(mines_left:int)
signal winned()

const OPEN_CELLS_DELAY : float = 0.05
const OPENED_CELL_PARTICLE = preload("uid://dsldgrg6c5kf0")

var _grid_set : GameGridSet = tile_set
var _mines_coords : Array[Vector2i] = []
var _opened_cells := 0
var _grid_size:Vector2i
var _is_game_over:=false
var _game_id:int=0

@export var viewport : SubViewport

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var cell := _get_cell_coord()
		if _is_cell_coord_valid(cell):
			get_viewport().set_input_as_handled()
			if _is_game_over:
				generate_grid(_grid_size.x, _grid_size.y, _mines_coords.size())
			else:
				if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
					open_cell(cell)
				elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
					_switch_cell(cell)

func _reset() -> void:
	_is_game_over=false
	_opened_cells = 0

func _switch_cell(coord: Vector2i)->void:
	var id := _get_cell_id(coord)
	
	if id == _grid_set.CELL:
		_set_cell(coord, _grid_set.FLAG_CELL)
		cell_switched.emit(coord)
	elif id == _grid_set.FLAG_CELL:
		_set_cell(coord, _grid_set.UNKNOWN_CELL)
		cell_switched.emit(coord)
	elif id == _grid_set.UNKNOWN_CELL:
		_set_cell(coord, _grid_set.CELL)
		cell_switched.emit(coord)

func open_cell(coord: Vector2i, force:bool=false) -> void:
	var temp_game_id:=_game_id
	var id:= _get_cell_id(coord)
	
	if id in _grid_set.NUMBERS:
		_try_open_neighbours(coord)
		return
	
	if id != _grid_set.CELL and not force:
		return
	
	if _has_mine(coord):
		_lose(coord)
	else:
		var mines:=_get_surrounded_mines(coord)
		if mines>0:
			_set_cell(coord, _grid_set.NUMBERS[mines-1])
			_try_open_neighbours(coord)
		else:
			_set_cell(coord, _grid_set.EMPTY_CELL)
			await get_tree().create_timer(OPEN_CELLS_DELAY).timeout
			if temp_game_id != _game_id or _is_game_over:
				return
			_open_empty_cells_recursive(coord)
		
		_create_opened_cell_particle(coord)
		
		_opened_cells += 1
		
		if get_closed_cells_count() - _mines_coords.size() == 0:
			_win()
	pass

func _lose(coord: Vector2i) -> void:
	var mines_left:=get_real_mines_left_count()
	_open_all_mines()
	_set_cell(coord, _grid_set.EXPLODE_MINE_CELL)
	_is_game_over=true
	losed.emit(mines_left)
	print("Lose!")

func _win() -> void:
	_set_all_mines_to_flags()
	_is_game_over=true
	winned.emit()
	print("Win!")

func _set_all_mines_to_flags() -> void:
	for i in _mines_coords:
		_set_cell(i, _grid_set.FLAG_CELL)

func get_cells_count(id:Vector2i) -> int:
	var count:int=0
	for x in _grid_size.x:
		for y in _grid_size.y:
			var coord:=Vector2i(x,y)
			var _id:=_get_cell_id(coord)
			if id == _id:
				count+=1
	return count

func get_fake_mines_left_count() -> int:
	return _mines_coords.size() - get_cells_count(_grid_set.FLAG_CELL)

func get_real_mines_left_count() -> int:
	var flags : int = 0
	for coord in _mines_coords:
		if _get_cell_id(coord) == _grid_set.FLAG_CELL:
			flags+= 1
	return _mines_coords.size() - flags

func get_closed_cells_count() -> int:
	return (_grid_size.x * _grid_size.y) - _opened_cells

func _create_opened_cell_particle(coord: Vector2i) -> void:
	var ins : Node2D = OPENED_CELL_PARTICLE.instantiate()
	ins.position = Vector2(coord * _grid_set.CELL_SIZE) + _grid_set.CELL_SIZE * 0.5
	get_parent().add_child(ins)

func _try_open_neighbours(coord: Vector2i) -> void:
	var temp_game_id:=_game_id
	var mines:=_get_surrounded_mines(coord)
	var flags:=_get_surrounded_flags(coord)
	
	if flags >= mines:
		for x in range(-1, 2):
			for y in range(-1, 2):
				var c := coord + Vector2i(x, y)
				var id := _get_cell_id(c)
				if id == _grid_set.CELL or id == _grid_set.UNKNOWN_CELL:
					open_cell(c, true)
					await get_tree().create_timer(OPEN_CELLS_DELAY).timeout
					if temp_game_id != _game_id or _is_game_over:
						return

func _open_all_mines() -> void:
	for x in _mines_coords:
		_set_cell(x, _grid_set.MINE_CELL)
	
	for x in _grid_size.x:
		for y in _grid_size.y:
			var coord:=Vector2i(x,y)
			if _get_cell_id(coord) == _grid_set.FLAG_CELL:
				_set_cell(coord, _grid_set.WRONG_FLAG_CELL)

func _open_empty_cells_recursive(coord:Vector2i) -> void:
	for x in range(-1, 2):
		for y in range(-1, 2):
			var c := coord + Vector2i(x, y)
			if not _has_mine(c):
				open_cell(c)

func _get_surrounded_flags(coord:Vector2i)->int:
	var flags:=0
	for x in range(-1, 2):
		for y in range(-1, 2):
			var c := coord + Vector2i(x, y)
			if _get_cell_id(c) == _grid_set.FLAG_CELL:
				flags+=1
	return flags

func _get_surrounded_mines(coord:Vector2i)->int:
	var mines:=0
	for x in range(-1, 2):
		for y in range(-1, 2):
			var c := coord + Vector2i(x, y)
			if _has_mine(c):
				mines+=1
	return mines

func _set_cell(coord: Vector2i, id:Vector2i) -> void:
	set_cell(coord, 0, id)

func _has_mine(coord: Vector2i) -> bool:
	return coord in _mines_coords

func _get_cell_id(coord: Vector2i) -> Vector2i:
	return get_cell_atlas_coords(coord)

func _is_cell_coord_valid(coord: Vector2i) -> bool:
	return coord.x > -1 and coord.y > -1 and \
		   coord.x < _grid_size.x and coord.y < _grid_size.y

func _get_cell_coord() -> Vector2i:
	return Vector2i(get_local_mouse_position()) / _grid_set.CELL_SIZE

func generate_easy_grid(width:int, height:int) -> void:
	@warning_ignore("integer_division")
	generate_grid(width, height, (width * height) / 8)
	
func generate_medium_grid(width:int, height:int) -> void:
	@warning_ignore("integer_division")
	generate_grid(width, height, (width * height) / 4)
	
func generate_hard_grid(width:int, height:int) -> void:
	@warning_ignore("integer_division")
	generate_grid(width, height, (width * height) / 2)

func generate_grid(width:int, height:int, mines:int) -> void:
	assert(width * height > mines, "Количество мин должно быть меньше количества клеток!")

	_reset()
	
	_grid_size = Vector2i(width,height)
	_game_id += 1

	clear()
	
	_mines_coords.clear()
	_mines_coords.resize(mines)
	var mines_populate:=0
	
	var cell_coords : Array[Vector2i] = []
	cell_coords.resize(width*height)
	
	var index:=0
	for x in width:
		for y in height:
			set_cell(Vector2i(x, y), 0, _grid_set.CELL)
			cell_coords[index] = Vector2i(x, y)
			index+=1
	
	while mines_populate < mines:
		_mines_coords[mines_populate] = cell_coords.pop_at(randi_range(0, cell_coords.size() - 1))
		mines_populate += 1
	
	grid_generated.emit(_grid_size, _mines_coords)
	print("Grid: {0}x{1} ({2} cells) with {3} mines - generated!".format([width, height, width*height, mines]))
	
	_resize_viewport()

func _resize_viewport() -> void:
	if not viewport:
		return
	viewport.size_2d_override = _grid_size * _grid_set.CELL_SIZE
