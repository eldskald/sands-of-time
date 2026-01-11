class_name PlayerSprite
extends Sprite2D

@onready var _player: Player = get_parent().get_parent() as Player
@onready var _pivot: Node2D = get_parent() as Node2D
@onready var _anim: AnimationPlayer = %AnimationPlayer
@onready var _throwing_timer: Timer = %ThrowingTimer

var _state_animations: Dictionary = {
	Player.State.STANDING: "standing",
	Player.State.MOVING: "moving",
	Player.State.JUMPING: "airborne",
	Player.State.AIRBORNE: "airborne",
	Player.State.LIFTING: "lift",
	Player.State.BOX_JUMPING: "box_jump",
	Player.State.DIGGING_DOWN: "digging_down",
	Player.State.DIGGING_FORWARD: "digging_forward",
	Player.State.DIGGING_UP: "digging_up",
}

var _carrying_state_animations: Dictionary = {
	Player.State.STANDING: "carrying_standing",
	Player.State.MOVING: "carrying_moving",
	Player.State.JUMPING: "carrying_airborne",
	Player.State.AIRBORNE: "carrying_airborne",
	Player.State.BOX_JUMPING: "box_jump",
}

var _throwing_state_animations: Dictionary = {
	Player.State.STANDING: "throwing_standing",
	Player.State.MOVING: "throwing_moving",
	Player.State.JUMPING: "throwing_airborne",
	Player.State.AIRBORNE: "throwing_airborne",
}

var _throwing_frames: Dictionary = {
	4: 20,
	5: 21,
	6: 22,
	7: 23,
	8: 24,
	28: 20,
	29: 21,
	30: 22,
	31: 23,
	32: 24,
	0: 18,
	1: 18,
	25: 18,
	26: 18,
	3: 19,
	27: 19,
}

var _reverse_throwing_frames: Dictionary = {
	18: 0,
	19: 3,
	20: 4,
	21: 5,
	22: 6,
	23: 7,
	24: 8,
}


func animate_throw() -> void:
	var state = _player.get_state()
	var current_time = _anim.current_animation_position
	_anim.play_section(_throwing_state_animations[state], current_time)
	frame = _throwing_frames[frame]
	_throwing_timer.start()


func _on_player_state_changed(new_state: Player.State) -> void:
	if _player.is_carrying():
		_anim.play(_carrying_state_animations[new_state])
	elif not _throwing_timer.is_stopped():
		_anim.play(_throwing_state_animations[new_state])
	else:
		_anim.play(_state_animations[new_state])


func _on_player_facing_changed(new_facing: float) -> void:
	_pivot.scale.x = new_facing


func _on_throwing_timer_timeout() -> void:
	var state = _player.get_state()
	if _player.is_carrying() or state == Player.State.LIFTING:
		return
	var current_time = _anim.current_animation_position
	_anim.play_section(_state_animations[state], current_time)
	frame = _reverse_throwing_frames[frame]
