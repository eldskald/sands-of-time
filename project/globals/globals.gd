extends Node

const game_screen_size = Vector2i(192, 144)

const _first_lv_coords = Vector2i(0, 0)
const _map = [
	[ 0,  1, -1, -1, -1],
	[-1,  2, -1, -1, -1],
	[-1,  3, -1, -1, -1],
	[-1,  4,  5,  7,  8],
	[-1,  6, 11, 10,  9],
]

@export var _levels: Array[PackedScene]

@onready var _main = get_node("/root/Main")
@onready var _player: Player = get_tree().get_nodes_in_group("player")[0]
@onready var _hud: HUD = get_tree().get_nodes_in_group("hud")[0]
@onready var _coords = _first_lv_coords

var _found_logs: Array[int] = []


func has_log(id: int) -> bool:
	return id in _found_logs


func add_log(id: int) -> void:
	_found_logs.append(id)
	_hud.add_log_button(id)


func get_player() -> Player:
	return _player


func get_hud() -> HUD:
	return _hud


func get_level() -> Level:
	return get_tree().get_nodes_in_group("level")[0] as Level


func load_first_level() -> void:
	_main.change_level(_levels[0])
	var start_pos = get_tree().get_nodes_in_group("player_starting_position")[0]
	_player.position = start_pos.position


func _go_up() -> void:
	_player.changing_level(true)
	_coords.y -= 1
	_player.position.y += game_screen_size.y
	_main.change_level(_levels[_map[_coords.y][_coords.x]])


func _go_down() -> void:
	_player.changing_level()
	_coords.y += 1
	_player.position.y -= game_screen_size.y
	_main.change_level(_levels[_map[_coords.y][_coords.x]])


func _go_left() -> void:
	_player.changing_level()
	_coords.x -= 1
	_player.position.x += game_screen_size.x
	_main.change_level(_levels[_map[_coords.y][_coords.x]])


func _go_right() -> void:
	_player.changing_level()
	_coords.x += 1
	_player.position.x -= game_screen_size.x
	_main.change_level(_levels[_map[_coords.y][_coords.x]])


func _physics_process(_delta: float) -> void:
	if _player.position.x >= Globals.game_screen_size.x:
		Globals._go_right()
	elif _player.position.x <= 0.0:
		Globals._go_left()
	elif _player.position.y >= Globals.game_screen_size.y:
		Globals._go_down()
	elif _player.position.y <= 0.0:
		Globals._go_up()
