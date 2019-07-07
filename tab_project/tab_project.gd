extends Control

signal units_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_dialog_button = $tab_master/vbox/mc/vbox/button_working_dir
	var file_dialog_popup = $tab_master/vbox/mc/vbox/button_working_dir/FileDialog
	
	var save_button = $tab_master/vbox/mc/vbox/button_save_data
	
	file_dialog_button.connect("button_up", self, "file_dialog")
	file_dialog_popup.connect("dir_selected", self, "set_working_dir")
	
	save_button.connect("button_up", self, "save_data")
	
	$tab_master/vbox/mc/vbox/input_proj_units/user_input.add_item("Imperial")
	$tab_master/vbox/mc/vbox/input_proj_units/user_input.add_item("Metric")
	pass # Replace with function body.

func file_dialog():
	var popup = $tab_master/vbox/mc/vbox/button_working_dir/FileDialog
	
	popup.popup_centered()
	return
	
func set_working_dir(dir):
	get_node("tab_master/vbox/mc/vbox/input_working_directory/user_input").set_text(dir)
	data_management.working_directory = dir
	print(dir)
	pass

func save_data():
	data_management.emit_signal("save_project")
	pass

func _on_user_input_item_selected(ID):
	emit_signal("units_changed")
	pass # Replace with function body.
