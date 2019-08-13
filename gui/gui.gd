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

	#for data management
	data_management.connect("save_project", self, "save_data")
#
	project_name = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_proj_name/user_input
	project_number = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_proj_number/user_input
	user_initials = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_user_initials/user_input
	working_dir = $mc/hbox/vbox/tab_cont/Project/tab_master/vbox/mc/vbox/input_working_directory/user_input
	
	save_data()
	pass # Replace with function body.

func save_data():
	data_management.project_name = project_name.get_text()
	data_management.dictionary_project_data["project_name"] = data_management.project_name
	data_management.project_number = project_number.get_text()
	data_management.dictionary_project_data["project_number"] = data_management.project_number
	data_management.user_initials = user_initials.get_text()
	data_management.dictionary_project_data["user_initials"] = data_management.user_initials
	data_management.working_dir = working_dir.get_text()
	data_management.dictionary_project_data["working_dir"] = data_management.working_dir
	print(project_name.get_text())
	data_management.save_data()
	pass