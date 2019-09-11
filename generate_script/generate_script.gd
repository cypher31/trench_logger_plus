extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_script(trench_specific_data, trench_row_data):
	data_management.save_data() #save data before creating script
	data_management.emit_signal("save_project")
	
	var date = OS.get_date()
	var date_formatted = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + "\r\n"
	var script_dict : Dictionary = {} #script dictionary
	var script_row_data : Dictionary = {} #row data manipulated to be printed

	var trench_number = trench_specific_data["trench_number"]

	script_dict[script_dict.size() + 1] = "; created" + date_formatted #key denotes the line number
	script_dict[script_dict.size() + 1] = "(setq oldosmode (getvar \"OSMODE\"))\r\n"
	script_dict[script_dict.size() + 1] = "OSMODE 0\r\n"
	script_dict[script_dict.size() + 1] = "SNAP OFF\r\n"
	script_dict[script_dict.size() + 1] = "-layout delete %s\r\n" % trench_number
	script_dict[script_dict.size() + 1] = "layout s master\r\n"
	script_dict[script_dict.size() + 1] = "-layout c master %s\r\n" % trench_number
	script_dict[script_dict.size() + 1] = "layout s %s\r\n" % trench_number
	script_dict[script_dict.size() + 1] = "clayer 0\r\n"
	script_dict[script_dict.size() + 1] = "-Insert\r\n"
	script_dict[script_dict.size() + 1] = "tlog\r\n"
	script_dict[script_dict.size() + 1] = "0,0\r\n"
	script_dict[script_dict.size() + 1] = "1\r\n"
	script_dict[script_dict.size() + 1] = "1\r\n"
	script_dict[script_dict.size() + 1] = "0\r\n"
	script_dict[script_dict.size() + 1] = "Project Name: %s\r\n" % data_management.project_name
	script_dict[script_dict.size() + 1] = "Project Number: %s\r\n" % data_management.project_number
	script_dict[script_dict.size() + 1] = "Equipment: %s\r\n" % trench_specific_data["trench_equipment"]
	script_dict[script_dict.size() + 1] = "Logged By: %s\r\n" % trench_specific_data["trench_logged_by"]
	script_dict[script_dict.size() + 1] = "Date: %s" % date_formatted
	script_dict[script_dict.size() + 1] = "Location: %s\r\n" % trench_specific_data["trench_location"]
	script_dict[script_dict.size() + 1] = "Trench No.: %s\r\n" % trench_specific_data["trench_number"]
	script_dict[script_dict.size() + 1] = "scale: 1in = %s ft\r\n" % trench_specific_data["trench_scale"]
	script_dict[script_dict.size() + 1] = "Elevation: %s' MSL\r\n" % trench_specific_data["trench_elevation"]
	script_dict[script_dict.size() + 1] = "Surface Slope: %s deg.\r\n" % trench_specific_data["trench_slope"]
	script_dict[script_dict.size() + 1] = "Trend: %s\r\n" % trench_specific_data["trench_trend"]
	script_dict[script_dict.size() + 1] = "ucs m .2,.2\r\n"
	
	var row_data_fixed : Dictionary = row_data(trench_row_data)

	for data in row_data_fixed:
		script_dict[script_dict.size() + 1] = row_data_fixed[data]
		pass
	
	script_dict[script_dict.size() + 1] = "-mtext 8.1,.9 s AR10 j tl w 1.9 Total Depth: %s\r\n Groundwater: %s\r\n Backfilled: %s" % [trench_specific_data["trench_total_depth"], trench_specific_data["trench_groundwater"], "Enter Date\r\n\r\n"]

	#generate trench outline
	var trench_outline : Dictionary = new_trench_outline(trench_specific_data["trench_total_depth"])
	
	script_dict[script_dict.size() + 1] = "pline\r\n"
	
	for data in trench_outline:
		script_dict[script_dict.size() + 1] = trench_outline[data]
		pass
	
	#extra clear
	script_dict[script_dict.size() + 1] = "\r\n"
	
	#generate geoatt within trench outline
	var k : int = 0
	
	var trench_outline_start = Vector2(trench_outline[1].strip_edges().split_floats(",")[0], trench_outline[1].strip_edges().split_floats(",")[1])
	var trench_outline_end = Vector2(trench_outline[trench_outline.size()].strip_edges().split_floats(",")[0], trench_outline[trench_outline.size()].strip_edges().split_floats(",")[1])

	var trench_centerline = (trench_outline_end + trench_outline_start) / 2

	var last_depth : float = trench_centerline.y
	
	for k in range(0, trench_row_data.size()):
		var x_pos : float = trench_centerline.x
		var y_pos_next : float

		if (k + 1) == trench_row_data.size():
			y_pos_next = trench_outline_start.y - float(trench_specific_data["trench_total_depth"]) / 5
		else:
			y_pos_next = (float(trench_row_data["trench_row_" + str(k+1)]["trench_depth"]) / 5)

		var y_pos : float = (last_depth + y_pos_next) / 2
		
		if trench_row_data["trench_row_" + str(k)]["trench_unit"] != "-":
			script_dict[script_dict.size() + 1] = "clayer 0\r\n"
			script_dict[script_dict.size() + 1] = "-Insert\r\n"
			script_dict[script_dict.size() + 1] = "geoatt\r\n"
			script_dict[script_dict.size() + 1] = "%s,%s\r\n" % [x_pos, y_pos]
			script_dict[script_dict.size() + 1] = "1\r\n"
			script_dict[script_dict.size() + 1] = "1\r\n"
			script_dict[script_dict.size() + 1] = "0\r\n"
			script_dict[script_dict.size() + 1] = (trench_row_data["trench_row_" + str(k)]["trench_unit"]) + "\r\n"
			script_dict[script_dict.size() + 1] = "pline\r\n%s,%s\r\n%s,%s\r\n\r\n" % [trench_outline_start.x, y_pos, trench_outline_end.x, y_pos]
			
			last_depth = last_depth - float(trench_row_data["trench_row_" + str(k)]["trench_depth"]) / 5
		k += 1
		pass
	
	#generate script file
	var file = File.new()
	var file_date = str(date["month"]) + "_" + str(date["day"]) + "_" + str(date["year"])
	var file_name = data_management.working_dir + "/" + file_date + "_" + trench_number + "_script.txt"
	
	file.open(file_name, file.WRITE)

	for i in range(1, script_dict.size() + 1):
		file.store_string(str(script_dict[i]))
		pass
	
	file.close()
	return


func row_data(data):
	var data_fixed : Dictionary = {}
	var x_pos_start : float = 0.5221 #0' depth position ; cylces through set values
	var y_pos_start : float = 6.15 #0' depth position ; cycles through set values based on # of rows
	var y_delta : float = 0.5 #vertical seperation between each trench data row 


	var all_x_pos : Array = [x_pos_start, 1.0647, 1.3, 6.7857, 7.4956, 8.2075, 8.9276, 9.6428]
	var all_y_pos: Array = [] #calc below

	for i in range(0, data.size()):
		all_y_pos.append(y_pos_start - i * y_delta)
		pass
	
	var i_x : int = 0
	var i_y : int = 0
	
	for row in data:
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.3 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_attitude"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.3 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tl w 4.95 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_description"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_geo_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_uscs"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_sample_no"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_moisture"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10 j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_density"]]
		
		i_x = 0
		i_y += 1
		pass
	return data_fixed

func new_trench_outline(td): #td = total depth of trench
	var outline_points : Dictionary = {}
	var start_point : Vector2 = Vector2(1.0, 2.7)
	var end_point : Vector2
	var trench_center : Vector2
	var total_side_lines
	var lines_left_chosen : Dictionary = {}
	var lines_bottom_chosen : Dictionary = {}
	var lines_right_chosen : Dictionary = {}
	var total_bot_lines = 3 #constant
	
	var current_pos_left_y : float = 2.7
	var current_pos_right_y : float

	total_side_lines = int(td)

	#assign lines

#	var lines_left : Array = [Vector2(0.0, 0.2), Vector2(0.0069801, 0.1998782), Vector2(0.0139513, 0.1995128), Vector2(0.02092, 0.1989029),Vector2(0.0278937, 0.1980453), Vector2(0.0348649, 0.1969376)]
#	var lines_right : Array = [Vector2(0.0, 0.2), Vector2(0.0069801, 0.1998782), Vector2(0.02092, 0.1989029),Vector2(0.0278937, 0.1980453), Vector2(0.0348649, 0.1969376)\
#	, Vector2(0.0415823, 0.1956295), Vector2(0.0483844, 0.1940591), Vector2(0.0551275, 0.1922523), Vector2(0.0618037, 0.1902112), Vector2(0.0684048, 0.1879382)]
	
	#calc center of trench
	if int(td) <= 5:
		trench_center = start_point + Vector2((5 / 5) / 2, -5/5)
	elif int(td) > 5 and int(td) <= 10:
		trench_center = start_point + Vector2((10 / 5) / 2, -10/5)
	elif int(td) > 10 and int(td) <= 15:
		trench_center = start_point + Vector2((15 / 5) / 2, -15/5)
	elif int(td) > 15:
		trench_center = start_point + Vector2((20 / 5) / 2, -15/5)
	
	end_point = start_point + trench_center
	
	#assign minimum unit vectors
	var unit_left_length = 0.5
	var unit_right_length = 0.5
	
	var unit_left_x : float = 0.707
	var unit_left_y : float = -0.707
	var unit_right_x : float = 0.707
	var unit_right_y : float = 0.707
	
	var multiplier : float = 0.25
	
	var left_end_generator : float = start_point.y - float(td) / 5
	var right_end_generator : float = start_point.y

	var i : int = 2
	#create trench left side
	while current_pos_left_y >= left_end_generator * (1.0 + multiplier):
		var rand_dir_x = rand_range(0, unit_left_x)
		var rand_dir_y = rand_range(unit_left_y, 0)

		if lines_left_chosen.size() == 0:
			lines_left_chosen[1] = start_point - Vector2(0.25, 0) #drawing needs to start @ 1 inch
			lines_left_chosen[2] = start_point
		else:
			lines_left_chosen[lines_left_chosen.size() + 1] = unit_left_length * Vector2(rand_dir_x, rand_dir_y) + lines_left_chosen[i - 1] #drawing needs to start @ 1 inch & be added to the last drawn line
		
		i += 1
		current_pos_left_y = lines_left_chosen[i - 1].y
		pass
	
	var left_final_depth = lines_left_chosen[lines_left_chosen.size()]
	var bottom_elevation = 2.70 - float(td) / 5.0
	var distance_to_bottom = abs(bottom_elevation - left_final_depth.y)
	
	#create trench bottom
	var j : int = 1
	for i in range(0,3):
		var rand_dir_x = rand_range(0, unit_right_x)
		var rand_dir_y = rand_range(0, unit_right_y)
		
		if i == 0:
			lines_bottom_chosen[lines_bottom_chosen.size() + 1] = Vector2(lines_left_chosen[lines_left_chosen.size()].x + 0.25, bottom_elevation)
		elif i == 1:
			lines_bottom_chosen[lines_bottom_chosen.size() + 1] = lines_bottom_chosen[lines_bottom_chosen.size()] + Vector2(0.5, 0)
		elif i == 2:
			lines_bottom_chosen[lines_bottom_chosen.size() + 1] = lines_bottom_chosen[lines_bottom_chosen.size()] + unit_right_length * Vector2(rand_dir_x, rand_dir_y)
			lines_right_chosen[lines_right_chosen.size() + 1] = lines_bottom_chosen[lines_bottom_chosen.size()] + unit_right_length * Vector2(rand_dir_x, rand_dir_y)
			
			j += 1
			current_pos_right_y = lines_right_chosen[j - 1].y
		pass

	#create trench right side
	while current_pos_right_y <= right_end_generator * (1.0 - multiplier):
		var rand_dir_x = rand_range(0, unit_right_x)
		var rand_dir_y = rand_range(0, unit_right_y)
		
		lines_right_chosen[lines_right_chosen.size() + 1] = unit_right_length * Vector2(rand_dir_x, rand_dir_y) + lines_right_chosen[lines_right_chosen.size()] #drawing needs to start @ 1 inch & be added to the last drawn line
		
		j += 1
		current_pos_right_y = lines_right_chosen[j - 1].y
		pass

	#connect last line
	lines_right_chosen[lines_right_chosen.size() + 1] = Vector2(lines_right_chosen[lines_right_chosen.size()].x + 0.25, start_point.y)
	lines_right_chosen[lines_right_chosen.size() + 1] = lines_right_chosen[lines_right_chosen.size()] + Vector2(0.25, 0)
	
	#create dictionary
	for i in range(1, lines_left_chosen.size() + 1):
		outline_points[outline_points.size() + 1] = str(lines_left_chosen[i].x) + "," + str(lines_left_chosen[i].y) + "\r\n"
		pass

	for i in range(1, lines_bottom_chosen.size() + 1):
		outline_points[outline_points.size() + 1] = str(lines_bottom_chosen[i].x) + "," + str(lines_bottom_chosen[i].y) + "\r\n"
		pass

	for i in range(1, lines_right_chosen.size() + 1):
		outline_points[outline_points.size() + 1] = str(lines_right_chosen[i].x) + "," + str(lines_right_chosen[i].y) + "\r\n"
		pass
	return outline_points