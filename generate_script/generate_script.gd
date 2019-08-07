extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_script(trench_specific_data, trench_row_data):
	data_management.save_data() #save data before creating script
	data_management.emit_signal("save_project")
	
	var date = OS.get_date()
	var date_formatted = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"])
	var script_dict : Dictionary = {} #script dictionary
	var script_row_data : Dictionary {} #row data manipulated to be printed

	var trench_number = trench_specific_data["trench_number"]

	script_dict[script_dict.size() + 1] = "; created " + date_formatted #key denotes the line number
	script_dict[script_dict.size() + 1] = "(setq oldosmode (getvar \"OSMODE\"))"
	script_dict[script_dict.size() + 1] = "OSMODE 0"
	script_dict[script_dict.size() + 1] = "SNAP OFF"
	script_dict[script_dict.size() + 1] = "-layout delete %s" % trench_number
	script_dict[script_dict.size() + 1] = "layout s master"
	script_dict[script_dict.size() + 1] = "-layout c master %s" % trench_number
	script_dict[script_dict.size() + 1] = "layout s %s" % trench_number
	script_dict[script_dict.size() + 1] = "clayer 0"
	script_dict[script_dict.size() + 1] = "-Insert"
	script_dict[script_dict.size() + 1] = "tlog"
	script_dict[script_dict.size() + 1] = "0,0"
	script_dict[script_dict.size() + 1] = "1"
	script_dict[script_dict.size() + 1] = "1"
	script_dict[script_dict.size() + 1] = "0"
	script_dict[script_dict.size() + 1] = "Project Name: %s" % data_management.project_name
	script_dict[script_dict.size() + 1] = "Project Number: %s" % data_management.project_number
	script_dict[script_dict.size() + 1] = "Equipment: %s" % trench_specific_data["trench_equipment"]
	script_dict[script_dict.size() + 1] = "Logged By: %s" % trench_specific_data["trench_logged_by"]
	script_dict[script_dict.size() + 1] = "Date: %s" % date_formatted
	script_dict[script_dict.size() + 1] = "Location: %s" % trench_specific_data["trench_location"]
	script_dict[script_dict.size() + 1] = "Trench No.: %s" % trench_specific_data["trench_number"]
	script_dict[script_dict.size() + 1] = "scale: 1in = %s ft" % trench_specific_data["trench_scale"]
	script_dict[script_dict.size() + 1] = "Elevation: %s' MSL" % trench_specific_data["trench_elevation"]
	script_dict[script_dict.size() + 1] = "Surface Slope: %s deg." % trench_specific_data["trench_slope"]
	script_dict[script_dict.size() + 1] = "Trend: %s" % trench_specific_data["trench_trend"]
	script_dict[script_dict.size() + 1] = "ucs m .2,.2" #something funky was up with this when messing at the office
	#Everything above this line does not require a location
	var row_data_fixed : Array = row_data(trench_row_data)

	for data in row_data_fixed:
		
		pass

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