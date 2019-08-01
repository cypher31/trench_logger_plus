extends Control

var trench_parent : String

var trench_date : String
var trench_number : String
var trench_location : String
var trench_logged_by : String
var trench_equipment : String
var trench_total_depth : String
var trench_elevation : String
var trench_groundwater : String
var trench_scale : String
var trench_slope : String
var trench_trend : String
var trench_row_data : Dictionary

var trench_dict : Dictionary = {

	}

# Called when the node enters the scene tree for the first time.
func _ready():
	$tab_master/vbox/mc/vbox/button_add_row.connect("button_up", self, "add_row")
	$tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/button_script.connect("button_up", self, "new_script")
	pass # Replace with function body.

func add_row():
	utility.add_data_row("user_input_trench_entry", $tab_master/vbox/mc/vbox/ScrollContainer/trench_data)
	pass
	

func update_trench_dict():
	trench_date = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_date/user_input.get_text()
	trench_number = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_number/user_input.get_text()
	trench_location = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_location/user_input.get_text()
	trench_logged_by = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_logged_by/user_input.get_text()
	trench_equipment = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_equipment/user_input.get_text()
	trench_total_depth = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_total_depth/user_input.get_text()
	trench_elevation = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_elevation/user_input.get_text()
	trench_groundwater = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_groundwater/user_input.get_text()
	trench_scale = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_scale/user_input.get_text()
	trench_slope = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_slope/user_input.get_text()
	trench_trend = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_trend/user_input.get_text()
	
	var trench_data = $tab_master/vbox/mc/vbox/ScrollContainer/trench_data
	var trench_rows = trench_data.get_children()
	
	for trench_row in trench_rows:
		for data_item in trench_row.get_children():
			trench_row_data[data_item.get_name()] = data_item.get_text()
			pass
		trench_dict["trench_row_" + str(trench_row.get_index())] = trench_row_data.duplicate()
		
		trench_row_data.clear()
		pass
	return trench_dict


func new_script():
	var trench_name : String = get_name()
	data_management.dictionary_trench_data[trench_name] = update_trench_dict() #send data to be saved
	
	generate_script(data_management.dictionary_trench_data[trench_name])
	
	pass