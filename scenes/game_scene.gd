extends CanvasLayer

@export var game_container: VBoxContainer
@export var menu_container: MenuContainer

func _ready() -> void:
	game_container.hide()
	menu_container.show()
