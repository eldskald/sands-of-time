extends Node

@onready var _bgm1: AudioStreamPlayer = $Ascend
@onready var _bgm2: AudioStreamPlayer = $EchoesOfEternity
@onready var _bgm3: AudioStreamPlayer = $MelodyEternal
@onready var _bgm4: AudioStreamPlayer = $PixelRiver
@onready var _bgm5: AudioStreamPlayer = $TakingPoison

@onready var _players: Array[AudioStreamPlayer] = [_bgm1, _bgm2, _bgm3, _bgm4, _bgm5]

var _started: bool = false

func start() -> void:
	if _started:
		return
	var rng = randi() % 5
	_players[rng].play()
	_started = true


func _on_bgm1_finished() -> void:
	var rng = randi() % 4 + 1
	_players[rng].play()


func _on_bgm2_finished() -> void:
	var rng = randi() % 4
	if rng >= 1:
		rng += 1
	_players[rng].play()


func _on_bgm3_finished() -> void:
	var rng = randi() % 4
	if rng >= 2:
		rng += 1
	_players[rng].play()


func _on_bgm4_finished() -> void:
	var rng = randi() % 4
	if rng >= 3:
		rng += 1
	_players[rng].play()


func _on_bgm5_finished() -> void:
	var rng = randi() % 4
	_players[rng].play()
