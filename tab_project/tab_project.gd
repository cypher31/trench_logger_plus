extends Control

signal units_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_dialog_button = $tab_master/vbox/mc/vbox/button_working_dir
	var file_dialog_popup = $tab_master/vbox/mc/vbox/button_working_dir/FileDialog
	
	var save_button = $tab_master/vbox/mc/vbox/button_save_data
	var load_button = $tab_master/vbox/mc/vbox/button_load_data
	var load_file_dialog = $tab_master/vbox/mc/vbox/button_load_data/file_search

	var button_new_trench = $tab_master/vbox/mc/vbox/button_add_trench
	var pop_up_new_trench = $tab_master/vbox/mc/vbox/button_add_trench/new_trench_pop
	
	var button_all_script = $tab_master/vbox/mc/vbox/button_all_scripts
	var pop_up_all_script = $tab_master/vbox/mc/vbox/button_all_scripts/all_script_popup
	
	var button_about = $tab_master/vbox/mc/vbox/button_about
	var pop_up_about = $tab_master/vbox/mc/vbox/button_about/about_pop
	
	file_dialog_button.connect("button_up", self, "file_dialog")
	file_dialog_popup.connect("dir_selected", self, "set_working_dir")
	
	save_button.connect("button_up", self, "save_data")
	load_button.connect("button_up", self, "load_data")
	
	load_file_dialog.connect("file_selected", self, "set_file_to_load")

	button_new_trench.connect("button_up", self, "new_trench")
	pop_up_new_trench.connect("confirmed", self, "new_trench_pop_up")
	
	button_all_script.connect("button_up", self, "all_script")
	pop_up_all_script.connect("confirmed", self, "all_script_pop_up")
	
	button_about.connect("button_up", self, "_about_popup")
	pass # Replace with function body.

func file_dialog():
	var popup : FileDialog = $tab_master/vbox/mc/vbox/button_working_dir/FileDialog
	
	popup._set_size(Vector2(750, 250))
	popup.set_current_dir("C:/Users/")
	popup.set_current_dir("C:/Users/kelby/dev/software/prototype/trench_logger_plus")
	popup.popup_centered()
	return
	
	
func _about_popup():
	var popup : WindowDialog = $tab_master/vbox/mc/vbox/button_about/about_pop
	
	popup._set_size(Vector2(750, 250))

	popup.popup_centered()
	return
	
func set_working_dir(dir):
	get_node("tab_master/vbox/mc/vbox/input_working_directory/user_input").set_text(dir)
	data_management.working_dir = dir
	print(dir)
	pass

func save_data():
	data_management.emit_signal("save_project")
	pass

func load_data():
	var popup = $tab_master/vbox/mc/vbox/button_load_data/file_search
	
	popup._set_size(Vector2(750, 250))
	popup.set_current_dir("C:/Users/")
	popup.set_current_dir("C:/Users/kelby/dev/software/prototype/trench_logger_plus")
	popup.popup_centered()
	pass

func set_file_to_load(file):
	data_management.load_data(file)
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
		utility.create_new_tab("tab_trench", pop_up_input)
	else:
		utility.output_node.set_text("Please Enter a Valid Name")
		pop_up.show()
	pass

func _on_user_input_item_selected(ID):
	emit_signal("units_changed")
	pass # Replace with function body.
	
	
func all_script():
	var pop_up = $tab_master/vbox/mc/vbox/button_all_scripts/all_script_popup
	pop_up.popup_centered()
	return
	
	
func all_script_pop_up():
	utility.emit_signal("generate_all_scripts")
	print(false)
	return
