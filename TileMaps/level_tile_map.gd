class_name LevelTileMap extends TileMap

func _ready() -> void:
	LevelManager.ChangeTileMapBounds(GetTileMapBounds())

func GetTileMapBounds() -> Array[Vector2]:
	var rect := get_used_rect()
	var tile_size := Vector2(tile_set.tile_size)

	var top_left := Vector2(rect.position) * tile_size
	var bottom_right := Vector2(rect.end) * tile_size

	top_left = to_global(top_left)
	bottom_right = to_global(bottom_right)

	return [
		top_left,
		bottom_right
	]
