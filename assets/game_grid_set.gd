extends TileSet
class_name GameGridSet

var CELL_SIZE := Vector2i(16, 16)

var ONE := Vector2i(0, 0)
var TWO := Vector2i(1, 0)
var THREE := Vector2i(2, 0)
var FOUR := Vector2i(3, 0)
var FIVE := Vector2i(0, 1)
var SIX := Vector2i(1, 1)
var SEVEN := Vector2i(2, 1)
var EIGHT := Vector2i(3, 1)

var NUMBERS : Array[Vector2i] = [ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT]

var EMPTY_CELL := Vector2i(0, 2)
var CELL := Vector2i(1, 2)
var FLAG_CELL := Vector2i(2, 2)
var WRONG_FLAG_CELL := Vector2i(3, 2)
var UNKNOWN_CELL := Vector2i(1, 3)
var MINE_CELL := Vector2i(2, 3)
var EXPLODE_MINE_CELL := Vector2i(3, 3)
