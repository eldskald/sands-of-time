class_name HUD
extends Control

@export var _game_viewport: NodePath

@onready var _player: Player = Globals.get_player()
@onready var _game_screen: TextureRect = %GameScreen
@onready var _level_title: Label = %LevelTitle
@onready var _prompt: Label = %Prompt
@onready var _first_text_container: CenterContainer = %FirstTextContainer
@onready var _final_text_container: CenterContainer = %FinalTextContainer
@onready var _first_text_label: Label = %FirstTextLabel
@onready var _final_text_label: Label = %FinalTextLabel
@onready var _shovel_btn: Button = %ShovelBtn
@onready var _red_shard_btn: Button = %RedShardBtn
@onready var _log_buttons: VBoxContainer = %LogButtons
@onready var _blip: AudioStreamPlayer = %BlipSFX
@onready var _new_log: AudioStreamPlayer = %NewLogSFX

var _next_prompt: String = ""


func _ready() -> void:
	var screen = get_node(_game_viewport) as Viewport
	_game_screen.texture = screen.get_texture()
	_game_screen.custom_minimum_size = Globals.game_screen_size


func _physics_process(_delta: float) -> void:
	_prompt.text = _next_prompt
	_next_prompt = ""


func add_log_button(id: int) -> void:
	var btn = LogButton.new()
	btn.log_id = id
	_log_buttons.add_child(btn)
	_new_log.play()


func set_level_title(new_title: String) -> void:
	_level_title.text = new_title


func set_prompt(new_prompt: String) -> void:
	_next_prompt = new_prompt


func set_text_box(text_1: String, text_2: String = "") -> void:
	if text_2:
		_first_text_label.text = text_1
		_final_text_label.text = text_2
		_first_text_container.show()
		_final_text_container.show()
	else:
		_final_text_label.text = text_1
		_final_text_container.show()
	get_tree().paused = true


func set_red_shards(amount: int) -> void:
	if not _red_shard_btn.visible:
		_red_shard_btn.show()
		set_text_box("Red shard obtained. Equip and click to throw.")
		_new_log.play()
	_red_shard_btn.text = str(amount) + "/4 R Shards"
	if amount == 0:
		_red_shard_btn.disabled = true
		_red_shard_btn.set_pressed_no_signal(false)
		_shovel_btn.set_pressed_no_signal(true)
		_player.equip_shovel()
	else:
		_red_shard_btn.disabled = false


func play_blip() -> void:
	_blip.play()


func _on_close_button_pressed() -> void:
	_final_text_container.hide()
	_final_text_label.text = ""
	get_tree().paused = false
	play_blip()


func _on_next_button_pressed() -> void:
	_first_text_container.hide()
	_first_text_label.text = ""
	play_blip()


func _on_game_screen_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("click"):
		Globals.get_player().click_on(event.position)


func _on_shovel_btn_pressed() -> void:
	_red_shard_btn.set_pressed_no_signal(false)
	_shovel_btn.set_pressed_no_signal(true)
	_player.equip_shovel()
	play_blip()


func _on_red_shard_btn_pressed() -> void:
	_red_shard_btn.set_pressed_no_signal(true)
	_shovel_btn.set_pressed_no_signal(false)
	_player.equip_shards()
	play_blip()
