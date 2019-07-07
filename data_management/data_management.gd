extends Node

var working_directory : String

var project_number : String
var project_name : String
var user_initials : String
var working_dir : String

var load_width : String
var load_length : String
var pressure : String
var x_loc : String
var y_loc : String
var resolution : String

var wall_height : String
var wall_resolution : String

var poissons : String

var dictionary_save : Dictionary = {
	"project_number" : project_number,
	"project_name" : project_name,
	"user_initials" : user_initials,
	"working_dir" : working_dir,
	"load_width" : load_width,
	"load_length" : load_length,
	"pressure" : pressure,
	"x_loc" : x_loc,
	"y_loc" : y_loc,
	"resolution" : resolution,
	"wall_height" : wall_height,
	"wall_resolution" : wall_resolution,
	"poissons" : poissons
	}
	
var dictionary_load : Dictionary = {}

signal save_project

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func save_data():
	var save_time = OS.get_datetime() #returns dictionary with following keys: year, month, day, hour, minute
	var save_year = save_time["year"]
	var save_month = save_time["month"]
	var save_day = save_time["day"]
	var save_hour = save_time["hour"]
	var save_min = save_time["minute"]
	
	var save_file_name = str(save_year) +"_"+ str(save_month) +"_"+ str(save_day) +"_"+ str(save_hour) +"_"+ str(save_min) +"_"+ str(project_number)
	
	#create save file
	#check if working directory has been selected...
	if working_dir != "":
		var save_project = File.new()
		save_project.open(working_dir + "/" + save_file_name + ".blep", File.WRITE)
		
		var data = dictionary_save
		
		save_project.store_line(to_json(data))
		save_project.close()
	else: #throw error - call popup
		get_tree().get_root().get_node("main/gui/set_working_dir_warning").popup_centered()
	return

