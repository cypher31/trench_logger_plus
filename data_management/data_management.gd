extends Node

var got_project_data = false

var working_directory : String

var project_number : String
var project_name : String
var user_initials : String
var working_dir : String

var dictionary_project_data : Dictionary = {
	"project_number" : project_number,
	"project_name" : project_name,
	"user_initials" : user_initials,
	"working_dir" : working_dir,
	}
	
var dictionary_trench_data : Dictionary = {

	}
	
signal save_project
signal load_project

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
	
	var save_file_name = str(save_year) +"_"+ str(save_month) + "_" + str(project_number)
	
	#create save file
	#check if working directory has been selected...
	if working_dir != "":
		var save_project = File.new()
		save_project.open(working_dir + "/" + save_file_name + ".tlp", File.WRITE)
#
		var data_project : Dictionary = dictionary_project_data
		var data_trench : Dictionary = dictionary_trench_data
#
		save_project.store_line(to_json(data_project))
		save_project.store_line(to_json(data_trench))
		save_project.close()
		
		var output_console : TextEdit = utility.output_node
		var output_text : String = output_console.get_text()
		var text_standard : String = "Project saved successfully. File name:"
		var date_time : Dictionary = OS.get_datetime() #year, month, day, weekday, dst (Daylight Savings Time), hour, minute, second.
		var day = date_time["day"]
		var month = date_time["month"]
		var hour = date_time["hour"]
		var minute = date_time["minute"]
		var text : String = output_text + "\r\n" + text_standard + " " + save_file_name + " Completed at %s:%s on %s/%s" % [hour, minute, month, day]
		
		utility.output_node.set_text(text)
	else: #throw error - call popup
		get_tree().get_root().get_node("main/PanelContainer/gui/set_working_dir_warning").popup_centered()
	return
	

func load_data(data_path):
	# create a file object
	var load_data = File.new()
	
	# see if the file actually exists before opening it
	if !load_data.file_exists(data_path):
		print ("File not found! Aborting...")
		return
	
	# use an empty dictionary to assign temporary data to
	var current_line = {}

	# read the data in
	load_data.open(data_path, File.READ)
	
	var i : int = 0 #line counter
	#there should only ever be two variables
	while(!load_data.eof_reached()):
		
		# use currentLine to parse through the file
		current_line = parse_json(load_data.get_line())

		# assign the data to the variables
		if i == 0:
			dictionary_project_data.clear()
			dictionary_project_data = current_line
		elif i == 1:
			dictionary_trench_data = current_line
			pass

		i += 1
#		proje  =  current_line["unlocked_items"]
#		global.arrHighScore = current_line["high_score"]
#		global.total_coins = current_line["total_coins"]
	
	load_data.close()
	
	for trench in dictionary_trench_data:
		if trench != "TP-1":
			utility.create_new_tab("tab_trench", trench)
	
	emit_signal("load_project")
	return

