class_name Messenger
extends InteractArea

@export_multiline var _message: String


func _ready() -> void:
	connect("interaction", _on_interaction)


func _on_interaction(_player: Player) -> void:
	_hud.set_text_box(_message)
