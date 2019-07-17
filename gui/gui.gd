extends Control

var data : Dictionary = {} # data dictionary
var data_to_send : Array = []

var project_number : Node
var project_name : Node
var user_initials : Node
var working_dir : Node
var load_width : Node
var load_length : Node
var pressure : Node
var x_loc : Node
var y_loc : Node
var resolution : Node
var wall_height : Node
var wall_resolution : Node
var poissons : Node

#unit definitions
var distance : String = "ft"
var pressure_unit : String = "psf"
var force : String = "lb/ft"

# Called when the node enters the scene tree for the first time.
func _ready():
	utility.output_node = $output
	
#	$mc/hbox/vbox/button_run.connect("button_up", self, "get_data") # connect button to function
#	$mc/hbox/vbox/button_run.connect("button_up", self, "send_data_to_visualize")
	
	
	#for data management
#	data_management.connect("save_project", self, "save_data")
#
#	project_name = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_proj_name/user_input
#	project_number = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_proj_number/user_input
#	user_initials = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_user_initials/user_input
#	working_dir = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_working_directory/user_input
#	load_width = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_load_size_width/user_input
#	load_length = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_load_size_length/user_input
#	pressure = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_intensity/user_input
#	x_loc = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_locationX/user_input
#	y_loc = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_locationY/user_input
#	resolution = $mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_resolution/user_input
#	wall_height = $mc/hbox/vbox/tab_cont/Wall/tab_master/vbox/mc/vbox/input_height/user_input
#	wall_resolution = $mc/hbox/vbox/tab_cont/Wall/tab_master/vbox/mc/vbox/input_resolution/user_input
#	poissons = $mc/hbox/vbox/tab_cont/Soil/tab_master/vbox/mc/vbox/input_poisson/user_input
#
#	$mc/hbox/vbox/tab_cont/Project.connect("units_changed", self, "update_units")
#
#	get_tree().set_debug_collisions_hint(true)
	pass # Replace with function body.

func get_data():
	var load_data = $mc/hbox/vbox/tab_cont/Loading.get_data() # run get data function at loading node
	var wall_data = $mc/hbox/vbox/tab_cont/Wall.get_data() # run get data function at wall node
	var soil_data = $mc/hbox/vbox/tab_cont/Soil.get_data() # run get data function at soil node
	
	data["load_data"] = load_data #add load data to dictionary
	data["wall_data"] = wall_data #add wall data to dictionary
	data["soil_data"] = soil_data #add soil data to dictionary
	run_analysis(data)
	pass
	
func run_analysis(data): #need to add data type checks
	var resultant : float = 0.0 # : float sets variable type
	var y_bar : float = 0.0 # set type
	
	var load_type : String = data["load_data"]["input_type"].to_lower()
	var load_intensity : float= data["load_data"]["input_intensity"].to_float()
	var load_location_x : float= data["load_data"]["input_locationX"].to_float() # distance to face of load (or center or point load)
	var load_location_y : float = data["load_data"]["input_locationY"].to_float() # distance load is "off center" from point of interest on wall
	
	#load area variables
	var load_width : float = data["load_data"]["input_load_size_width"].to_float()
	var load_length : float = data["load_data"]["input_load_size_length"].to_float()
	var load_resolution : int = data["load_data"]["input_resolution"].to_float()
	
	var wall_height : float = data["wall_data"]["input_height"].to_float()
	var wall_resolution : float = data["wall_data"]["input_resolution"].to_float() # number of resultants along the wall to calculate
	var wall_unit_height : float = wall_height / wall_resolution # unit length along wall : based on resolution

	var soil_poisson : float = data["soil_data"]["input_poisson"].to_float()
	
	var z : float = float(wall_unit_height) # analysis location along wall height

	#analysis logic
	if load_type == "point": # logic if user has selected a point load type
		var resultants = calculate_point_resultant(load_intensity, load_location_x, load_location_y, wall_height, wall_resolution, wall_unit_height, z, soil_poisson)
		
		var resultant_net = calculate_point_area(resultants)
		var y_bar_calc = calculate_point_y_bar(resultants)

		resultant = resultant_net[0]
		y_bar = y_bar_calc
		
		output_results(resultant, y_bar)
		pass
		
	if load_type == "area": # logic if an area load is selected
		var unit_load_locations : Array = []
		
		var dx : float = 0.0 # how much to tick position in x direction when moving to next row
		var dy : float = 0.0 # how much to tick position in y direction when moving to next unit_load
		
		#calculate number of unit loads
		var unit_load_count : int = pow(load_resolution, 2)
		
		#calculate unit area dimensions
		var load_unit_width : float = load_width / load_resolution
		var load_unit_length : float = load_length / load_resolution
		
		dx = load_unit_width
		dy = load_unit_length

		var first_unit_load_position : Vector2 = Vector2(load_location_y, load_location_x) - Vector2(load_length / 2, 0) + Vector2(dy / 2,dx / 2)
		var current_unit_load_position : Vector2 = first_unit_load_position # center of the unit_load
		var next_unit_load_position : Vector2 = Vector2()

		#calculate unit area intensity (point load)
		load_intensity = load_intensity * load_unit_width * load_unit_length

		#calculate load_intensity positions
		for i in range(0, unit_load_count):
			var position : Vector2 = current_unit_load_position
			
			#append current position
			unit_load_locations.append(position)
			
			#get next position
			if (int(i) % int(load_resolution - 1)) != 0 or i == 0:
				next_unit_load_position = current_unit_load_position + Vector2(dy, 0)
			elif (int(i) % int(load_resolution - 1)) == 0 && i != 0:
				next_unit_load_position = Vector2(first_unit_load_position.x, current_unit_load_position.y + dx)
				pass
			
			current_unit_load_position = next_unit_load_position
		pass

		var answer : Array = [] # holds results from calculations
		var resultant_array : Array = []
		var y_bar_array : Array = []

		for location in unit_load_locations:
			load_location_x = location.y
			load_location_y = location.x
#
			var resultants = calculate_point_resultant(load_intensity, load_location_x, load_location_y, wall_height, wall_resolution, wall_unit_height, z, soil_poisson)
			
			for item in resultants:
				resultant_array.append(item)
				pass
			pass
		
		var resultant_net = calculate_point_area(resultant_array)

		var y_bar_calc = calculate_point_y_bar(resultant_net[1])
		
		output_results(resultant_net[0], y_bar_calc)
		pass
	pass
	
func calculate_point_resultant(load_intensity, load_location_x, load_location_y, wall_height, wall_resolution, wall_unit_height, z, soil_poisson):
	var resultant : float = 0.0 # : float sets variable type
	var resultants = [] # holds calculated resultants
		
	while z <= wall_height: # while z is less than the total wall height
		var r : float = sqrt(pow(load_location_x,2) + pow(load_location_y,2)) # distance from z to wall face
		var R : float = sqrt(pow(z,2) + pow(r,2)) # R variable from Bowles book
		var p : float = 0.0 # resultant holder
		
		var factor1 = load_intensity / (2 * PI) # first factor of general equation
		var factor2 = (3 * pow(r,2) * z) / pow(R,5) # second factor of general equation
		var factor3 = (1 - 2 * soil_poisson) / (R*(R+z)) # third factor of general equation
		
		p =  factor1 * (factor2 - factor3) # calculate sigma r (general equation)

#		if z < 2.5: #for hand calc checking, set this value for the depth you are calculating
#			print("NEW RUN~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
#			print(load_location_x)
#			print(load_location_y)
#			print(r)
#			print(z)
#			print(R)
#			print(factor1)
#			print(factor2)
#			print(factor3)
#			print(p)
			
		resultants.append([p, z]) # add data for this depth point to resultant array 
		z += wall_unit_height # increment z by the unit wall length
		pass
	
	var load_type : String = data["load_data"]["input_type"].to_lower()

	return resultants


func calculate_point_area(r): # calculate the area beneath the trapezoid generated by connecting resultant ends
							# method of trapezoids
	var load_type : String = data["load_data"]["input_type"].to_lower()
	var wall_height : float = data["wall_data"]["input_height"].to_float()

	var i : int = 0
	var resultant_row_dict : Dictionary = {}
	var resultant_rows_summed : Array = []

	for resultant in r:
		if resultant_row_dict.has(str(resultant[1])):
			resultant_row_dict[str(resultant[1])].append(resultant[0])
		else:
			resultant_row_dict[str(resultant[1])] = [resultant[0]]
		pass

	var resultant_row_sum_array : Array = []

	for key in resultant_row_dict:
		var resultants_sum : float = 0.0
		for resultant in resultant_row_dict[key]:
			resultants_sum += resultant
			pass
		resultant_row_sum_array.append(resultants_sum)
		pass

	var a = 0 # assume top of wall sees no load 
	var b = wall_height # height of wall
	var n = resultant_row_sum_array.size() # total number of points along wall to calculate

	var factor1 = (b - a) / (2 * n) # (b - a) / 2 * n : is the first factor of area of sequential trapezoids
	
	var area_sum : float = 0.0  #sum of 2 * y # : series of trapezoids method
	
	for i in resultant_row_sum_array:
		if i != resultant_row_sum_array.back():
			area_sum += 2 * i
		else:
			area_sum += i
		pass

	var total_area : float = factor1 * area_sum
	
	data_to_send = resultant_row_sum_array
	
	return [total_area, resultant_row_dict]
	
func calculate_point_y_bar(r):
	var resultants_parsed : Array = []
	
	if typeof(r) == TYPE_DICTIONARY:
		for key in r:
			var resultants_sum : float = 0.0
			for resultant in r[key]:
				resultants_sum += resultant
				pass
			resultants_parsed.append([resultants_sum, float(key)])
			pass
	elif typeof(r) == TYPE_ARRAY:
		resultants_parsed = r
		pass
	
	r = resultants_parsed
	
	var centroid : Vector2 = Vector2(0,0) #centroid of load
	var signed_area : float = 0.0
	
	var x0 : float = 0.0 #current vertex
	var y0 : float = 0.0 #current vertex
	var x1 : float = 0.0 #next vertex
	var y1 : float = 0.0 #next vertex
	var a : float = 0.0 #partial signed area
	
	var i : int = 0
	#for all verticies except last
	for j in range(0, r.size()-1):
		x0 = r[j][1]
		y0 = r[j][0]
		x1 = r[j+1][1]
		y1 = r[j+1][0]
		
		signed_area += a
		a = x0*y1 - x1*y0
		centroid.x += (x0 + x1) * a
		centroid.y += (y0 + y1) * a
		
		i += 1
		pass
		
	x0 = r[i][1]
	y0 = r[i][0]
	x1 = r[0][1]
	y1 = r[0][0]

	a = x0*y1 - x1*y0
	signed_area *= 0.5
	
	centroid.x /= (signed_area * 6.0)
	centroid.y /= (signed_area * 6.0)
	
	return centroid[0]
	
func output_results(resultant, y_bar):
	$mc/hbox/vbox/output.set_text(str("R = " + str(resultant) + " " + force + "\ny_bar = " + str(y_bar) + " " + distance + " : from top of wall")) # output solution to program console
	pass
	

func send_data_to_visualize():
	var data : Array = data_to_send
	
	$mc/hbox/vbox2/scene_visualize_loads/Panel.set_data(data)
	pass
	
	
func save_data():
	data_management.project_name = project_name.get_text()
	data_management.dictionary_save["project_name"] = data_management.project_name
	data_management.project_number = project_number.get_text()
	data_management.dictionary_save["project_number"] = data_management.project_number
	data_management.user_initials = user_initials.get_text()
	data_management.dictionary_save["user_initials"] = data_management.user_initials
	data_management.working_dir = working_dir.get_text()
	data_management.dictionary_save["working_dir"] = data_management.working_dir
	data_management.load_width = load_width.get_text()
	data_management.dictionary_save["load_width"] = data_management.load_width
	data_management.load_length = load_length.get_text()
	data_management.dictionary_save["load_length"] = data_management.load_length
	data_management.pressure = pressure.get_text()
	data_management.dictionary_save["pressure"] = data_management.pressure
	data_management.x_loc = x_loc.get_text()
	data_management.dictionary_save["x_loc"] = data_management.x_loc
	data_management.y_loc = y_loc.get_text()
	data_management.dictionary_save["y_loc"] = data_management.y_loc
	data_management.resolution = resolution.get_text()
	data_management.dictionary_save["resolution"] = data_management.resolution
	data_management.wall_height = wall_height.get_text()
	data_management.dictionary_save["wall_height"] = data_management.wall_height
	data_management.wall_resolution = wall_resolution.get_text()
	data_management.dictionary_save["wall_resolution"] = data_management.wall_resolution
	data_management.poissons = poissons.get_text()
	data_management.dictionary_save["poissons"] = data_management.poissons
	
	data_management.save_data()
	pass
	

func update_units():
	#change units depending on what is currently set
	if distance == "ft":
		distance = "m"
		pressure_unit = "kN/m^2"
		force = "kN/m"
	else:
		distance = "ft"
		pressure_unit = "psf"
		force = "lb/ft"

	$mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_load_size_width/input_units.set_text(distance)
	$mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_load_size_length/input_units.set_text(distance)
	$mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_intensity/input_units.set_text(pressure_unit)
	$mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_locationX/input_units.set_text(distance)
	$mc/hbox/vbox/tab_cont/Loading/tab_master/vbox/mc/vbox/input_locationY/input_units.set_text(distance)
	$mc/hbox/vbox/tab_cont/Wall/tab_master/vbox/mc/vbox/input_height/input_units.set_text(distance)

	pass