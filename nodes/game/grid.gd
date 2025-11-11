extends TileMapLayer

var _grid_set : GameGridSet = tile_set
var _mines_coords : Array[Vector2i] = []
var _opened_cells := 0
var _grid_size:Vector2i
var _is_game_over:=false

@export var camera : Camera2D

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

func _switch_cell(coord: Vector2i)->void:
	var id := _get_cell_id(coord)
	
	if id == _grid_set.CELL:
		_set_cell(coord, _grid_set.FLAG_CELL)
	elif id == _grid_set.FLAG_CELL:
		_set_cell(coord, _grid_set.UNKNOWN_CELL)
	elif id == _grid_set.UNKNOWN_CELL:
		_set_cell(coord, _grid_set.CELL)

func open_cell(coord: Vector2i) -> void:
	var id:= _get_cell_id(coord)
	
	if id in _grid_set.NUMBERS:
		_try_open_neighbours(coord)
		return
	
	if id != _grid_set.CELL:
		return
	
	if _has_mine(coord):
		_open_all_mines()
		_set_cell(coord, _grid_set.EXPLODE_MINE_CELL)
		_is_game_over=true
	else:
		var mines:=_get_surrounded_mines(coord)
		if mines>0:
			_set_cell(coord, _grid_set.NUMBERS[mines-1])
			_try_open_neighbours(coord)
		else:
			_set_cell(coord, _grid_set.EMPTY_CELL)
			_open_empty_cells_recursive(coord)
		
		_opened_cells += 1
		
		if _opened_cells == (_grid_size.x * _grid_size.y) - _mines_coords.size():
			_is_game_over=true
	pass

func _try_open_neighbours(coord: Vector2i) -> void:
	var mines:=_get_surrounded_mines(coord)
	var flags:=_get_surrounded_flags(coord)
	
	if flags >= mines:
		for x in range(-1, 2):
			for y in range(-1, 2):
				var c := coord + Vector2i(x, y)
				if _get_cell_id(c) == _grid_set.CELL:
					open_cell(c)

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
	
func generate_normal_grid(width:int, height:int) -> void:
	@warning_ignore("integer_division")
	generate_grid(width, height, (width * height) / 4)
	
func generate_hard_grid(width:int, height:int) -> void:
	@warning_ignore("integer_division")
	generate_grid(width, height, (width * height) / 2)

func generate_grid(width:int, height:int, mines:int) -> void:
	assert(width * height > mines, "Количество мин должно быть меньше количества клеток!")

	_grid_size = Vector2i(width,height)
	_is_game_over=false
	_opened_cells = 0

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
	
	_centering_camera()

func _centering_camera() -> void:
	if not camera:
		return
	camera.position = Vector2(_grid_size) * (_grid_set.CELL_SIZE / 2.0)
