extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_script(trench_specific_data, trench_row_data):
	data_management.save_data() #save data before creating script
	data_management.emit_signal("save_project")
	
	var date = OS.get_date()
	var date_formatted = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + " \r\n"
	var script_dict : Dictionary = {} #script dictionary
	var script_row_data : Dictionary = {} #row data manipulated to be printed

	var trench_number = trench_specific_data["trench_number"]

	script_dict[script_dict.size() + 1] = "; created" + date_formatted #key denotes the line number
	script_dict[script_dict.size() + 1] = "(setq oldosmode (getvar \"OSMODE\")) \r\n"
	script_dict[script_dict.size() + 1] = "OSMODE 0 \r\n"
	script_dict[script_dict.size() + 1] = "SNAP OFF \r\n"
	script_dict[script_dict.size() + 1] = "-layout delete %s \r\n" % trench_number
	script_dict[script_dict.size() + 1] = "layout s master \r\n"
	script_dict[script_dict.size() + 1] = "-layout c master %s \r\n" % trench_number
	script_dict[script_dict.size() + 1] = "layout s %s \r\n" % trench_number
	script_dict[script_dict.size() + 1] = "clayer 0 \r\n"
	script_dict[script_dict.size() + 1] = "-Insert \r\n"
	script_dict[script_dict.size() + 1] = "tlog \r\n"
	script_dict[script_dict.size() + 1] = "0,0 \r\n"
	script_dict[script_dict.size() + 1] = "1 \r\n"
	script_dict[script_dict.size() + 1] = "1 \r\n"
	script_dict[script_dict.size() + 1] = "0 \r\n"
	script_dict[script_dict.size() + 1] = "Project Name: %s \r\n" % data_management.project_name
	script_dict[script_dict.size() + 1] = "Project Number: %s \r\n" % data_management.project_number
	script_dict[script_dict.size() + 1] = "Equipment: %s \r\n" % trench_specific_data["trench_equipment"]
	script_dict[script_dict.size() + 1] = "Logged By: %s \r\n" % trench_specific_data["trench_logged_by"]
	script_dict[script_dict.size() + 1] = "Date: %s" % date_formatted
	script_dict[script_dict.size() + 1] = "Location: %s \r\n" % trench_specific_data["trench_location"]
	script_dict[script_dict.size() + 1] = "Trench No.: %s \r\n" % trench_specific_data["trench_number"]
	script_dict[script_dict.size() + 1] = "scale: 1in = %s ft \r\n" % trench_specific_data["trench_scale"]
	script_dict[script_dict.size() + 1] = "Elevation: %s' MSL \r\n" % trench_specific_data["trench_elevation"]
	script_dict[script_dict.size() + 1] = "Surface Slope: %s deg. \r\n" % trench_specific_data["trench_slope"]
	script_dict[script_dict.size() + 1] = "Trend: %s \r\n" % trench_specific_data["trench_trend"]
	script_dict[script_dict.size() + 1] = "ucs m .2,.2 \r\n" #something funky was up with this when messing at the office
	#Everything above this line does not require a location
	var row_data_fixed : Dictionary = row_data(trench_row_data)

	for data in row_data_fixed:
		script_dict[script_dict.size() + 1] = row_data_fixed[data]
		pass
	
	script_dict[script_dict.size() + 1] = "-mtext 8.1,.9 s AR10 jk tl w 1.9 Total Depth: %s \r\n Groundwater: %s \r\n Backfilled: %s" % [trench_specific_data["trench_total_depth"], trench_specific_data["trench_groundwater"], "Enter Date \r\n"]
	
	print(script_dict)
	#reference
#	trench_project_dict["trench_date"] = trench_date
#	trench_project_dict["trench_number"] = trench_number
#	trench_project_dict["trench_location"] = trench_location
#	trench_project_dict["trench_logged_by"] = trench_logged_by
#	trench_project_dict["trench_equipment"] = trench_equipment
#	trench_project_dict["trench_total_depth"] = trench_total_depth
#	trench_project_dict["trench_elevation"] = trench_elevation
#	trench_project_dict["trench_groundwater"] = trench_groundwater
#	trench_project_dict["trench_scale"] = trench_scale
#	trench_project_dict["trench_slope"] = trench_slope
#	trench_project_dict["trench_trend"] = trench_trend

	return


func row_data(data):
	var data_fixed : Dictionary = {}
	var x_pos_start : float = 1.0 #0' depth position ; cylces through set values
	var y_pos_start : float = 6.15 #0' depth position ; cycles through set values based on # of rows
	var y_delta : float = 0.5 #vertical seperation between each trench data row 


	var all_x_pos : Array = [x_pos_start, 1.0647, 1.3, 7.0, 7.4956, 7.6, 7.8, 8]
	var all_y_pos: Array = [] #calc below

	for i in range(0, data.size()):
		all_y_pos.append(y_pos_start - i * y_delta)
		pass
	
	var i_x : int = 0
	var i_y : int = 0
	
	for row in data:
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_attitude"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tl w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_description"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_geo_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_uscs"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_sample_no"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_moisture"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w %s \r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_density"]]
		
		i_y += 1
		pass
	return data_fixed