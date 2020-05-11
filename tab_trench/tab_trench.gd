extends Control

var trench_parent : String

var trench_date_node : Node
var trench_number_node : Node
var trench_location_node : Node
var trench_logged_by_node : Node
var trench_equipment_node : Node
var trench_total_depth_node : Node
var trench_elevation_node : Node
var trench_groundwater_node : Node
var trench_scale_node : Node
var trench_slope_node : Node
var trench_trend_node : Node

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

var trench_project_dict : Dictionary = {}
var trench_dict : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var pop_up_delete = $delete_popup
	
	pop_up_delete.connect("confirmed", self, "_delete_popup")
	
	$tab_master/vbox/mc/vbox/hbox/mc1/button_add_row.connect("button_up", self, "add_row")
	$tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/button_script.connect("button_up", self, "new_script", ["single"])
	utility.connect("generate_all_scripts", self, "new_script", ["all"])
	
	$tab_master/vbox/mc/vbox/hbox/mc2/button_delete_trench.connect("button_up", self, "_show_delete_popup")
	
	$tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_number/user_input.set_text(get_name())
	
	data_management.connect("save_project", self, "update_trench_dict")
	data_management.connect("load_project", self, "load_trench_data")
	
	trench_date_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_date/user_input
	trench_number_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_number/user_input
	trench_location_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_location/user_input
	trench_logged_by_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_logged_by/user_input
	trench_equipment_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_equipment/user_input
	trench_total_depth_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_total_depth/user_input
	trench_elevation_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_elevation/user_input
	trench_groundwater_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_groundwater/user_input
	trench_scale_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_scale/user_input
	trench_slope_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_slope/user_input
	trench_trend_node = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_right/user_input_trend/user_input

	
	#tab name managmenet
	var trench_name_box : LineEdit = $tab_master/vbox/mc/vbox/trench_descriptions/vbox_left/user_input_trench_number/user_input
	trench_name_box.connect("text_changed", self, "_update_tab_name")
	##
	pass # Replace with function body.

func add_row():
	var current_row_count = $tab_master/vbox/mc/vbox/ScrollContainer/trench_data.get_child_count()
	utility.add_data_row("user_input_trench_entry", $tab_master/vbox/mc/vbox/ScrollContainer/trench_data, current_row_count)
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
	
	trench_project_dict["trench_date"] = trench_date
	trench_project_dict["trench_number"] = trench_number
	trench_project_dict["trench_location"] = trench_location
	trench_project_dict["trench_logged_by"] = trench_logged_by
	trench_project_dict["trench_equipment"] = trench_equipment
	trench_project_dict["trench_total_depth"] = trench_total_depth
	trench_project_dict["trench_elevation"] = trench_elevation
	trench_project_dict["trench_groundwater"] = trench_groundwater
	trench_project_dict["trench_scale"] = trench_scale
	trench_project_dict["trench_slope"] = trench_slope
	trench_project_dict["trench_trend"] = trench_trend
	
	var trench_data = $tab_master/vbox/mc/vbox/ScrollContainer/trench_data
	var trench_rows = trench_data.get_children()
	
	for trench_row in trench_rows:
		for data_item in trench_row.get_children():
			
			if data_item is TextureButton:
				pass
			else:
				if data_item.get_text() != "":
					trench_row_data[data_item.get_name()] = data_item.get_text()
				else:
					trench_row_data[data_item.get_name()] = ""
				pass
				
		trench_dict["trench_row_" + str(trench_row.get_index())] = trench_row_data.duplicate()
		
		trench_row_data.clear()
		pass
	
	var trench_name : String = get_name()
	data_management.dictionary_trench_data[trench_name] = [trench_project_dict, trench_dict]
	return [trench_project_dict, trench_dict]


func new_script(button):
	var trench_name : String = get_name()
	data_management.dictionary_trench_data[trench_name] = update_trench_dict() #send data to be saved
	
	var data = data_management.dictionary_trench_data[trench_name]
	var file_name : String
	
#	var date = OS.get_date()
#	var date_formatted = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + "\r\n"
#	var file_date = str(date["month"]) + "_" + str(date["day"]) + "_" + str(date["year"])
	
#	if button == "all":
#		trench_name = "ALL_TRENCHES"
#		pass
	
#	file_name = data_management.working_dir + "/" + file_date + "_" + trench_name + "_script.txt"
	
	generate_script.new_script(data[0], data[1])
	pass
	
	
func load_trench_data():
	trench_date_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_date"])
	trench_number_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_number"])
	trench_location_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_location"])
	trench_logged_by_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_logged_by"])
	trench_equipment_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_equipment"])
	trench_total_depth_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_total_depth"])
	trench_elevation_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_elevation"])
	trench_groundwater_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_groundwater"])
	trench_scale_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_scale"])
	trench_slope_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_slope"])
	trench_trend_node.set_text(data_management.dictionary_trench_data[get_name()][0]["trench_trend"])
	
	#check how many rows there are. If more than 1 row generate number of rows needed
	for i in range(0, data_management.dictionary_trench_data[get_name()][1].size() - 1):
		add_row()
		pass
	
	#place data
	for j in range(0, data_management.dictionary_trench_data[get_name()][1].size()):
		var current_row = get_node("tab_master/vbox/mc/vbox/ScrollContainer/trench_data/trench_input_row_" + str(j))

		current_row.get_node("trench_depth").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_depth"])
		current_row.get_node("trench_attitude").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_attitude"])
		current_row.get_node("trench_unit").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_unit"])
		current_row.get_node("trench_description").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_description"])
		current_row.get_node("trench_geo_unit").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_geo_unit"])
		current_row.get_node("trench_uscs").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_uscs"])
		current_row.get_node("trench_sample_no").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_sample_no"])
		current_row.get_node("trench_moisture").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_moisture"])
		current_row.get_node("trench_density").set_text(data_management.dictionary_trench_data[get_name()][1]["trench_row_" + str(j)]["trench_density"])
		pass
		
	pass
	
func _update_tab_name(new_text : String):
	self.set_name(new_text)
	return
	
	
func _show_delete_popup():
	var pop_up = $delete_popup
	pop_up.popup_centered()
	return
	
func _delete_popup():
	var pop_up = $delete_popup
	var pop_up_input = pop_up.get_node("vbox/LineEdit").get_text()
	
	if pop_up_input.length() > 0:
		if pop_up_input == self.get_name():
			utility.delete_trench(self)
	else:
#		utility.output_node.set_text("Please Enter a Valid Name")
		pop_up.show()
	return
