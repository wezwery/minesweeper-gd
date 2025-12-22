extends Node

const DIFFICULTIES_DIR_PATH = "res://resources/difficulties/"
const RECORDS_DIR_PATH = "user://records/"
const SIZES = preload("uid://cjv4ye2l45bis").grids

var DIFFICULTIES : Array[Difficulty]
var RECORDS : Array[Record]

func _ready() -> void:
	_load_difficulties()
	_load_records()

func _load_difficulties() -> void:
	for f in ResourceLoader.list_directory(DIFFICULTIES_DIR_PATH):
		if f.ends_with(".tres"):
			DIFFICULTIES.append(load(DIFFICULTIES_DIR_PATH + f))
	DIFFICULTIES.sort_custom(func(a:Difficulty, b:Difficulty):return a.mines_populate<b.mines_populate)

func find_difficulty_by_name(difficulty_name:String) -> Difficulty:
	for x in DIFFICULTIES:
		if x.name == difficulty_name:
			return x
	return null

func find_difficulty_by_mines_populate(mines_populate:float)->Difficulty:
	for x in DIFFICULTIES:
		if x.mines_populate == mines_populate:
			return x
	return null

func register_win(preset:GamePreset, elapsed_time:int) -> bool:
	var diff_name = preset.difficulty.name
	var rec = get_record(diff_name, preset.grid_size)
	if not rec:
		rec = Record.new()
		rec.difficulty_name = preset.difficulty.name
		rec.elapsed_time = elapsed_time
		rec.grid_size = preset.grid_size
		RECORDS.append(rec)
		print("Record {0} - {1}x{2} - {3} registered!".format([diff_name, preset.grid_size.x,preset.grid_size.y,Tools.get_time(elapsed_time)]))
		save_records()
		return true
	elif rec.elapsed_time > elapsed_time:
		rec.elapsed_time = elapsed_time
		print("Record {0} - {1}x{2} - {3} updated!".format([diff_name, preset.grid_size.x,preset.grid_size.y,Tools.get_time(elapsed_time)]))
		save_records()
		return true
	return false

func get_record(difficulty_name : String, grid_size : Vector2i) -> Record:
	for r in RECORDS:
		if r.difficulty_name == difficulty_name and r.grid_size == grid_size:
			return r
	return null 

func save_records() -> void:
	for f in ResourceLoader.list_directory(RECORDS_DIR_PATH):
		if f.ends_with(".tres"):
			DirAccess.remove_absolute(RECORDS_DIR_PATH + f)
	
	for r in RECORDS:
		ResourceSaver.save(r, RECORDS_DIR_PATH + "{0}-{1}x{2}-{3}".format([r.difficulty_name, r.grid_size.x,r.grid_size.y, r.elapsed_time]) + ".tres")
	
	print("Records saved!")

func _load_records() -> void:
	RECORDS.clear()
	if DirAccess.dir_exists_absolute(RECORDS_DIR_PATH):
		for f in ResourceLoader.list_directory(RECORDS_DIR_PATH):
			if f.ends_with(".tres"):
				RECORDS.append(load(RECORDS_DIR_PATH + f))
	else:
		DirAccess.make_dir_recursive_absolute(RECORDS_DIR_PATH)
	print("Records loaded!")
