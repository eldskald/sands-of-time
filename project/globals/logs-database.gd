class_name LogsDatabase
extends Node

const _logs = [
	{# id 0
		title = "Graffiti 1",
		text_1 = "[Dated to 200~300 years old, written on a wall]\nDown with King Torgen!",
		text_2 = "",
	},
	{# id 1
		title = "Graffiti 2",
		text_1 = "[Dated to 200~300 years old, a drawing of a cat on a wall]",
		text_2 = "",
	},
	{# id 2
		title = "Graffiti 3",
		text_1 = "[Dated to 300~400 years old, written on a stone balcony railing]\nIrvin was here",
		text_2 = "",
	},
	{# id 3
		title = "Float Box 1",
		text_1 = "[Dated to around 350 years old, research notes]\n... Refined Blue Crystal when enchanted can easily defy gravity. Some of the engineers would float with it and jump off of it in midair, reaching new heights.",
		text_2 = "Need more experiments to build an airship, but we might be able to build personal levitators.",
	},
	{# id 4
		title = "Float Box 2",
		text_1 = "[Dated to around 350 years old, research notes]\n... Blue Crystal is a volatile substance, we need to develop a method to mine ir properly if we don't want another disaster on the mines.",
		text_2 = "",
	},
]

static func get_log(id: int) -> Dictionary:
	return _logs[id]
