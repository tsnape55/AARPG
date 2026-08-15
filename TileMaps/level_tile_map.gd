class_name LevelTileMap extends TileMap

func _ready() -> void:
	LevelManager.ChangeTileMapBounds(GetTileMapBounds())

func GetTileMapBounds() -> Array[Vector2]:
	var layer := get_child(0) as TileMapLayer
	
	if layer == null:
		return []

	var used_rect := layer.get_used_rect()
	var tile_size := layer.tile_set.tile_size

	return [
		Vector2(used_rect.position) * Vector2(tile_size),
		Vector2(used_rect.end) * Vector2(tile_size)
	]
