extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$tab_master/vbox/mc/vbox/button_add_row.connect("button_up", self, "add_row")
	pass # Replace with function body.

func add_row():
	utility.add_data_row("user_input_trench_entry", $tab_master/vbox/mc/vbox/ScrollContainer/trench_data)
	pass
