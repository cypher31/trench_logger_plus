extends Control

signal units_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_dialog_button = $tab_master/vbox/mc/vbox/button_working_dir
	var file_dialog_popup = $tab_master/vbox/mc/vbox/button_working_dir/FileDialog
	
	var save_button = $tab_master/vbox/mc/vbox/button_save_data
	
	var button_new_trench = $tab_master/vbox/mc/vbox/button_add_trench
	var pop_up_new_trench = $tab_master/vbox/mc/vbox/button_add_trench/new_trench_pop
	
	file_dialog_button.connect("button_up", self, "file_dialog")
	file_dialog_popup.connect("dir_selected", self, "set_working_dir")
	
	save_button.connect("button_up", self, "save_data")
	
	button_new_trench.connect("button_up", self, "new_trench")
	pop_up_new_trench.connect("confirmed", self, "new_trench_pop_up")
	
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

func new_trench():
	var pop_up = $tab_master/vbox/mc/vbox/button_add_trench/new_trench_pop
	
	pop_up.popup_centered()
	pass
	
func new_trench_pop_up():
	var pop_up = $tab_master/vbox/mc/vbox/button_add_trench/new_trench_pop
	var pop_up_input = pop_up.get_node("vbox/LineEdit").get_text()
	
	if pop_up_input.length() > 0:
		pop_up.hide()
	else:
		utility.output_node.set_text("Please Enter a Valid Name")
		pop_up.show()
	pass

func _on_user_input_item_selected(ID):
	emit_signal("units_changed")
	pass # Replace with function body.
