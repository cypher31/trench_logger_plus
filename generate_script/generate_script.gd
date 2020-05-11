extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_script(trench_specific_data, trench_row_data):
	data_management.emit_signal("save_project")
	
	var date = OS.get_date()
	var date_formatted = str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + "\r\n"
	var script_dict : Dictionary = {} #script dictionary
	var script_row_data : Dictionary = {} #row data manipulated to be printed

	var trench_number = trench_specific_data["trench_number"]

	script_dict[script_dict.size() + 1] = ";created" + date_formatted #key denotes the line number
#	script_dict[script_dict.size() + 1] = "(setq oldosmode (getvar \"OSMODE\"))\r\n"
#	script_dict[script_dict.size() + 1] = "OSMODE 0\r\n"
	script_dict[script_dict.size() + 1] = "SNAP OFF\r\n"
	script_dict[script_dict.size() + 1] = "-layout delete %s\r\n" % trench_number
	script_dict[script_dict.size() + 1] = "-layout s master\r\n"
	script_dict[script_dict.size() + 1] = "-layout c master\r\n"
	script_dict[script_dict.size() + 1] = "%s\r\n" % trench_number
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
	
	script_dict[script_dict.size() + 1] = "-mtext 8.1,.9 s AR10\r\n j tl w 1.9 Total Depth: %s\r\n Groundwater: %s\r\n Backfilled: %s" % [trench_specific_data["trench_total_depth"], trench_specific_data["trench_groundwater"], "Enter Date\r\n\r\n"]

	#generate trench outline
	var trench_outline : Dictionary = new_trench_outline(trench_specific_data["trench_total_depth"], trench_specific_data["trench_scale"])
	
	script_dict[script_dict.size() + 1] = "pline\r\n"
	
	#create commands for soil data
	for data in trench_outline:
		script_dict[script_dict.size() + 1] = trench_outline[data]
		pass
	
	#extra clear
	script_dict[script_dict.size() + 1] = "\r\n"
	
	#variables for creating commands for geo unit and contact positions
	var k : int = 0
	
	var trench_outline_start = Vector2(trench_outline[1].strip_edges().split_floats(",")[0], trench_outline[1].strip_edges().split_floats(",")[1])
	var trench_outline_end = Vector2(trench_outline[trench_outline.size()].strip_edges().split_floats(",")[0], trench_outline[trench_outline.size()].strip_edges().split_floats(",")[1])
	
	var trench_start_end : Vector2 = Vector2(trench_outline_start.x, trench_outline_end.x)
	
	var trench_centerline = (trench_outline_end + trench_outline_start) / 2

	var last_depth : float = trench_centerline.y
	
	var data_size = trench_row_data.size()
	
	var unit_data = get_unit_data(trench_row_data)
	
	var trench_total_depth = trench_specific_data["trench_total_depth"]
	
	var unit_positions = get_unit_positions(unit_data, trench_centerline, trench_total_depth, trench_specific_data["trench_scale"])
	
	#create commands for inserting geo units
	for data in unit_positions[0]:
		script_dict[script_dict.size() + 1] = unit_positions[0][data]
		pass
	
	var contact_positions = get_contact_positions(unit_data, trench_start_end, trench_centerline, trench_specific_data["trench_scale"])
	
	#create commands for drawing contact lines
	for data in contact_positions:
		script_dict[script_dict.size() + 1] = contact_positions[data]
		pass
	
	#check if sloped trench or not
	var trench_slope : float = float(trench_specific_data["trench_slope"])
	
	if trench_slope > 0.0:
		var trench_slope_line = get_trench_slope_line(trench_slope, trench_outline_end)
		
		for data in trench_slope_line:
			script_dict[script_dict.size() + 1] = trench_slope_line[data]
			pass
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
	var y_delta : float = 0.25 #vertical seperation between each trench data row 


	var all_x_pos : Array = [x_pos_start, 1.0647, 1.3, 6.7857, 7.4956, 8.2075, 8.9276, 9.6428]
	var all_y_pos: Array = [] #calc below

	for i in range(0, data.size()):
		all_y_pos.append(y_pos_start - i * y_delta)
		pass
	
	var i_x : int = 0
	var i_y : int = 0
	
	for row in data:
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.3 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_attitude"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.3 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tl w 4.95 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_description"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_geo_unit"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_uscs"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_sample_no"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_moisture"]]
		i_x += 1
		data_fixed[data_fixed.size() + 1] = "-mtext %s,%s s AB10\r\n j tc w 0.7 %s\r\n\r\n" % [all_x_pos[i_x], all_y_pos[i_y], data[row]["trench_density"]]
		
		i_x = 0
		i_y += 1
		pass
	return data_fixed

func new_trench_outline(td, ts): #td = total depth of trench, ts = trench scale
	var outline_points : Dictionary = {}
	var start_point : Vector2 = Vector2(1.0, 2.7)
	var end_point : Vector2
	var trench_center : Vector2
	var total_side_lines
	var lines_left_chosen : Dictionary = {}
	var lines_bottom_chosen : Dictionary = {}
	var lines_right_chosen : Dictionary = {}
	var total_bot_lines = 3 #constant
	var trench_scale : float = float(ts)
	
	var current_pos_left_y : float = 2.7
	var current_pos_right_y : float

	total_side_lines = float(td)

	#assign lines
	trench_center = start_point + Vector2(float(td) / trench_scale - 1, 0) / 2
	
	end_point = trench_center * Vector2(2,1)

	#assign minimum unit vectors
	var unit_left_length : float
	var unit_right_length : float
	var unit_angle_min_left : float
	var unit_angle_max_left : float
	var unit_angle_min_right : float
	var unit_angle_max_right : float
	
	
	if float(td) <= 10:
		unit_angle_min_left = deg2rad(315)
		unit_angle_max_left = deg2rad(270)
		
		unit_angle_min_right = deg2rad(45)
		unit_angle_max_right = deg2rad(90)
		
		unit_left_length = 0.10
		unit_right_length = 0.10
	else:
		unit_angle_min_left = deg2rad(315)
		unit_angle_max_left = deg2rad(270)
		
		unit_angle_min_right = deg2rad(45)
		unit_angle_max_right = deg2rad(90)
		
		unit_left_length = 0.10
		unit_right_length = 0.10
	
#	var unit_left_x : float = unit_angle_min
#	var unit_left_y : float = -unit_angle_min
#	var unit_right_x : float = unit_angle_min
#	var unit_right_y : float = unit_angle_min
	
	var multiplier : float = 0.5
	
	var left_end_generator : float = start_point.y - float(td) / trench_scale
	var right_end_generator : float = start_point.y

	var i : int = 2
	#create trench left side
	while current_pos_left_y >= left_end_generator + unit_left_length:
		var rand_angle = rand_range(unit_angle_min_left, unit_angle_max_left)

		if lines_left_chosen.size() == 0:
			lines_left_chosen[1] = start_point - Vector2(0.25, 0) #drawing needs to start @ 1 inch
			lines_left_chosen[2] = start_point
		else:
			lines_left_chosen[lines_left_chosen.size() + 1] = Vector2(unit_left_length * cos(rand_angle), unit_left_length * sin(rand_angle)) + lines_left_chosen[i - 1] #drawing needs to start @ 1 inch & be added to the last drawn line
		
		i += 1
		current_pos_left_y = lines_left_chosen[i - 1].y
		pass
	
	var left_final_depth = lines_left_chosen[lines_left_chosen.size()]
	var bottom_elevation = 2.70 - float(td) / trench_scale
	var distance_to_bottom = abs(bottom_elevation - left_final_depth.y)
	
	#create trench bottom
	var bot_elev = 2.7 - float(td) / trench_scale
	
	lines_bottom_chosen[lines_bottom_chosen.size() + 1] = Vector2(lines_left_chosen[lines_left_chosen.size()].x + 0.1,bot_elev)
	lines_bottom_chosen[lines_bottom_chosen.size() + 1] = Vector2(lines_left_chosen[lines_left_chosen.size()].x,0) + Vector2(3.0 / trench_scale, bot_elev)
	lines_left_chosen[lines_left_chosen.size() + 1] = lines_bottom_chosen[lines_bottom_chosen.size() - 1]
	lines_right_chosen[lines_right_chosen.size() + 1] = lines_bottom_chosen[lines_bottom_chosen.size()]
	
	current_pos_right_y = lines_right_chosen[lines_right_chosen.size()].y
	
	#create trench right side
	while current_pos_right_y <= right_end_generator * (1.0 - 0.1):
		var rand_angle = rand_range(unit_angle_min_right, unit_angle_max_right)
		lines_right_chosen[lines_right_chosen.size() + 1] = Vector2(unit_left_length * cos(rand_angle), unit_left_length * sin(rand_angle)) + lines_right_chosen[lines_right_chosen.size()] #drawing needs to start @ 1 inch & be added to the last drawn line
		
		current_pos_right_y = lines_right_chosen[lines_right_chosen.size() - 1].y
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
	
	
	
func get_unit_data(trench_row_data : Dictionary):
	var unit_data : Dictionary = {}
	
	for row in trench_row_data:
		if trench_row_data[row]["trench_unit"] != "":
			unit_data[unit_data.size() + 1] = trench_row_data[row]
	return unit_data
	
	
func get_unit_positions(unit_data : Dictionary, trench_centerline, trench_total_depth, ts): #ts = trench_scale
	var data_size : int = unit_data.size()
	var unit_positions : Dictionary = {}
	var total_depth : float = float(trench_total_depth)
	var center_line : Vector2 = trench_centerline
	var trench_scale : float = float(ts)
	
	var contact_positions : Dictionary = {}
	
	unit_positions[unit_positions.size() + 1] = "clayer 0\r\n"
	
	for i in range(0, data_size):
		var unit_x_pos : float = trench_centerline.x
		var unit_y_pos : float
		var unit : String = unit_data[i + 1]["trench_unit"]
		
		var contact_start : float
		var contact_end : float
		
		#Will need a check here for sloped or not sloped condition. Equations will need modification
		if i + 1 == data_size:
			contact_start = float(unit_data[i + 1]["trench_depth"]) / trench_scale #this needs to be changed to the scale eventually
			contact_end = trench_centerline.y - total_depth / trench_scale #will need to be given scale eventually
			unit_y_pos = contact_end + (total_depth / trench_scale - contact_start) / 2
		else:
			contact_start = float(unit_data[i + 1]["trench_depth"]) / trench_scale #this needs to be changed to the scale eventually
			contact_end = float(unit_data[i + 2]["trench_depth"]) / trench_scale #will need to be given scale eventually
			unit_y_pos = trench_centerline.y - (contact_start + contact_end) / 2
		
		var unit_position : Vector2
		
		unit_position = Vector2(unit_x_pos, unit_y_pos)
		
		contact_positions[i] = unit_position
		
		unit_positions[unit_positions.size() + 1] = "-Insert\r\n"
		unit_positions[unit_positions.size() + 1] = "geoatt\r\n"
		unit_positions[unit_positions.size() + 1] = "%s,%s\r\n" % [unit_position.x, unit_position.y]
		unit_positions[unit_positions.size() + 1] = "1\r\n"
		unit_positions[unit_positions.size() + 1] = "1\r\n"
		unit_positions[unit_positions.size() + 1] = "0\r\n"
		unit_positions[unit_positions.size() + 1] = "%s\r\n" % unit
	return [unit_positions, contact_positions]


func get_contact_positions(positions : Dictionary, trench_start_end, trench_centerline, ts): #ts = trench_Scale
	var contact_positions : Dictionary = {}
	var draw_length_mod : float = 0.4 #how far to draw past the edges of the trench
	var trench_scale : float = float(ts)
	
	for i in range(1, positions.size() + 1):
		var depth : float = float(positions[i]["trench_depth"]) / trench_scale
		
		if depth != 0.0:
			var line_y = (trench_centerline.y - depth)
			var line_x1 = trench_start_end.x
			var line_x2 = trench_start_end.y

			contact_positions[contact_positions.size() + 1] = "line\r\n"
			contact_positions[contact_positions.size() + 1] = "%s,%s\r\n" % [line_x1, line_y]
			contact_positions[contact_positions.size() + 1] = "%s,%s\r\n"  % [line_x2, line_y]
			contact_positions[contact_positions.size() + 1] = "\r\n"
		pass

	return contact_positions
	
	

func get_trench_slope_line(trench_slope, trench_outline_end):
	var trench_slope_line : Dictionary
	var slope : float = deg2rad(trench_slope)
	var start_point : Vector2 = trench_outline_end - Vector2(0.25,0)
	var end_point : Vector2
	var deltaX : float
	var deltaY : float
	
	deltaX = 6 #end of line will be 6 inches to the left of start point
	deltaY = deltaX*tan(slope)
	
	end_point = start_point - Vector2(deltaX, deltaY)

	trench_slope_line[trench_slope_line.size() + 1] = "line\r\n"
	trench_slope_line[trench_slope_line.size() + 1] = "%s,%s\r\n" % [start_point.x, start_point.y]
	trench_slope_line[trench_slope_line.size() + 1] = "%s,%s\r\n"  % [end_point.x, end_point.y]
	trench_slope_line[trench_slope_line.size() + 1] = "\r\n"
	return trench_slope_line
