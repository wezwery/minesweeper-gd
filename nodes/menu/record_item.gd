extends PanelContainer
class_name RecordItem

@export var diff_name: Label
@export var grid_size: Label
@export var elapsed_time: Label

func populate(record : Record) -> void:
	diff_name.text = record.difficulty_name
	grid_size.text = "{0}x{1}".format([record.grid_size.x,record.grid_size.y])
	elapsed_time.text = Tools.get_time(record.elapsed_time)
