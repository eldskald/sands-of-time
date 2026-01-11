class_name Level
extends Node2D

@export var _title: String

@onready var _dirt_map: TileMapLayer = $DirtLayer


func get_title() -> String:
	return _title


func clear_dirt(points: Array[Vector2]) -> int:
	var arr: Array[Vector2i] = []
	var cleared: int = 0
	for point in points:
		if _dirt_map.get_cell_tile_data(point as Vector2i):
			cleared += 1
			arr.push_back(point as Vector2i)
	_dirt_map.set_cells_terrain_connect(arr, 0, -1)
	return cleared


func fill_dirt(points: Array[Vector2]) -> int:
	var arr: Array[Vector2i] = []
	var filled: int = 0
	for point in points:
		if not _dirt_map.get_cell_tile_data(point as Vector2i):
			filled += 1
			arr.push_back(point as Vector2i)
	_dirt_map.set_cells_terrain_connect(arr, 0, 0)
	return filled
