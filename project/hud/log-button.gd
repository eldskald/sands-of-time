class_name LogButton
extends Button

@export var log_id: int


func _ready() -> void:
	var data = LogsDatabase.get_log(log_id)
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	text = data.title
	connect("pressed", _on_pressed)


func _on_pressed() -> void:
	var hud = Globals.get_hud()
	var data = LogsDatabase.get_log(log_id)
	hud.set_text_box(data.text_1, data.text_2)
	hud.play_blip()
