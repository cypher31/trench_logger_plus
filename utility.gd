extends Node

#global utility script
#this script holds common functions that can be called by the game at any time

#general signals

#project specific signals

#project specific variables
var output_node : Node


#devic info variables
var deviceType
var deviceWindowSize
var inputDevice = "keyboard"
const FILE_NAME = "user://state.save";


#layout holder
#var layoutHolder = []

#start base resolution
var resolution = Vector2(1280, 720)
#end base resolution

#object scene dictionary
var user_input_trench_entry = preload("res://user_input_trench_entry/user_input_trench_entry.tscn")

var object_scene_dict = {
	"user_input_trench_entry" : user_input_trench_entry
	}

#tab scene dictionary
var tab_trench = preload("res://tab_trench/tab_trench.tscn")

var tab_scene_dictionary = {
	"tab_trench" : tab_trench
	}

signal generate_all_scripts

func _ready():
	randomize()
	
	#global signals
#	connect("loopObject", self, "loopObject")
#	connect("generateCollider", self, "generate2DCollider")

	#get device info
	deviceWindowSize = OS.get_window_size()
	var screen_size = OS.get_screen_size(0)
	
	#center window to screen
	OS.set_window_position(screen_size * .5 - deviceWindowSize * .5)
	pass

	
func create_new_tab(tab_type, tab_name):
	var tab_container = get_tree().get_current_scene().get_node("PanelContainer/gui/mc/hbox/vbox/tab_cont")
	var new_tab_instance = tab_scene_dictionary[tab_type].instance()
	
	new_tab_instance.set_name(tab_name)
	tab_container.add_child(new_tab_instance)
	pass


func add_data_row(row_scene, row_container, current_row_count):
	var new_row_instance = object_scene_dict[row_scene].instance()
	
	row_container.add_child(new_row_instance)
	new_row_instance.set_name("trench_input_row_" + str(current_row_count))
	pass
	

func delete_trench(trench):
	trench.queue_free()
	return
	
	
func start_load_data(full_trench_dict):
	var tab_container = get_tree().get_current_scene().get_node("PanelContainer/gui/mc/hbox/vbox/tab_cont")
	var tab_child_count = tab_container.get_child_count()

	if tab_child_count > 1:
		for i in range(1, tab_child_count):
			var curr_child = tab_container.get_child(i)
			if curr_child.get_name() != "project":
				curr_child.queue_free()
		return true

	return true
	
	
func generate_trenches_to_load(full_trench_dict):
	var tab_container = get_tree().get_current_scene().get_node("PanelContainer/gui/mc/hbox/vbox/tab_cont")
	for trench in full_trench_dict:
			if tab_container.has_node(trench):
				tab_container.get_node(trench).free()
				create_new_tab("tab_trench", trench)
			else:
				create_new_tab("tab_trench", trench)
	
	data_management.emit_signal("load_project")
	return
