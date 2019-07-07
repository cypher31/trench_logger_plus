extends Node

#global utility script
#this script holds common functions that can be called by the game at any time

#general signals

#devic info variables
var deviceType
var deviceWindowSize
var inputDevice = "keyboard"
const FILE_NAME = "user://state.save";


#layout holder
#var layoutHolder = []

#start base resolution
var resolution = Vector2(1280, 720)
#end base resolution

#start set margin
#var sideMargin = 128 #pixels
#var topMargin = 128 #pixels
#var columnMargin = 64 #pixels
#end set margin


#player variables (for saving and for the player script to grab)
var final_score = 0

var playerVariableDict = {
#	"health" : maxHealth,
#	"boostFuel" : maxBoostFuel,
#	"bombCount" : startBombCount,
#	"shotTime" : shotTime,
	}

# stored variables
var __gameState = {
	"HIGHSCORES": []
};

#asset dictionary

var assetDict = {

	}

#stage scene dictionary

var stageSceneDict = {

}


#object scene dictionary

var objectSceneDict = {

	}

#music dictionary

var musicDict = {

	}

#sound sfx dictionary

var sfxDict = {

	}

func _ready():
	randomize()
	
	#global signals
#	connect("loopObject", self, "loopObject")
#	connect("generateCollider", self, "generate2DCollider")

	#get device info
	deviceWindowSize = OS.get_window_size()
	var screen_size = OS.get_screen_size(0)
	
	#center window to screen
	OS.set_window_position(screen_size * .5 - deviceWindowSize * .5)
	pass


#func readTextFile(f, d): #file, destination
#	#function for reading through a text file and generating enemies
#	var file = File.new()
#
#	if f != null:
#		file.open(f, file.READ)
#		pass
#
#	var text = file.get_as_text()
#	var jsonToText = JSON.parse(text)
#
#	d.emit_signal("newText", jsonToText.result, "layout")
#	pass
	
	
#func spawnEnemies(enemies, row): #to spawn
#	var y = 0
#	var count = 0
#	var startPosition = Vector2(128 + 64/2,128 + 32)
#
#	for enemy in enemies:
#		if enemy == 1:
#			var instanceEnemy = enemyDict["1"].instance()
#
#			get_node("/root/main/gameSceneCam/gameStage").add_child(instanceEnemy)
#			instanceEnemy.set_position(Vector2(startPosition.x + 64 * count,startPosition.y + 64 * y))
#
#			count += 1
#		else:
#			count += 1
#	pass
	
	
func sceneSwitch(scene): #add a "self" variable so the current scene can free itself before spawning the new screen
	var instanceScene = stageSceneDict[scene].instance()
	
	get_node("/root/main/PanelContainer").add_child(instanceScene)
	
#	instanceScene.set_position(Vector2(-960, -540))
	pass
	

func spawnObject(object, parent, position):
	var objectToInstance = object.instance()
	
	parent.add_child(objectToInstance)
	
	if objectToInstance.has_node("spawn"):
		var spawnPosition = objectToInstance.get_node("spawn").get_global_position();
		
		#move object to be spawned by the delta of given position and spawn node
		objectToInstance.set_global_position(position - spawnPosition)
	elif position != null:
		objectToInstance.set_global_position(position)
	else:
		pass
	pass
	

#func loopObject(object, position, velocity, ignore):
#	var direction = -velocity
#	var ray2D = RayCast2D.new()
#
#	object.add_child(ray2D)
#	ray2D.set_as_toplevel(true)
#	ray2D.set_enabled(true)
#	ray2D.add_exception(ignore)
#	ray2D.set_global_position(position)
#	ray2D.set_collide_with_areas(true)
#	ray2D.set_collide_with_bodies(false)
#	ray2D.set_cast_to(direction * 100)
#	ray2D.force_raycast_update()
#	if ray2D.is_colliding():
#		object.set_global_position(ray2D.get_collision_point())
##		ray2D.queue_free()
#	pass

func getGameState():
	return __gameState;
#
#func generate2DCollider(verticies, collisionNode):
#	var object = collisionNode.get_parent()
#	var poolArray = []
#	var vertexDirection = Vector2()
#
#	for vertex in verticies:
#		vertexDirection = vertex.normalized()
#		poolArray.append(vertex + vertexDirection)
#		pass
#
#	poolArray = PoolVector2Array(poolArray)
#
#	collisionNode.set_polygon(poolArray)
#	return;

func __saveGameState():
	var gameState = getGameState();
	var fileApi = File.new();
	
	fileApi.open("user://savegame.save", File.WRITE);
	fileApi.store_line(to_json(gameState));
	fileApi.close();
	return;

#func saveHighscores (highscoreInfo : Dictionary):
#	var pos = highscoreInfo.pos;
#	var initials = highscoreInfo.initials;
#	var score = highscoreInfo.score;
#
#	var highscores = utility.getHighscores();
#	var outHighscores = [];
#	var count = 0;
#	for i in range(0, highscores.size()):
#		if (pos == i):
#			outHighscores.append({'pos': pos, 'initials': initials, 'score': score});
#			count += 1;
#
#		var currHighscoreInfo = highscores[i];
#		currHighscoreInfo.pos = count;
#		outHighscores.append(currHighscoreInfo);
#		continue;
#
#	# getting the current game state and updating its HIGHSCORES property.
#	var gameState = getGameState();
#	gameState.HIGHSCORES = highscores;
#
#	__saveGameState();
#	return;

#func getHighscores () -> Array:
#	var highscoresArr = getGameState().HIGHSCORES;
#
#	# if not an array, or no highscores, let make sure there aren't any saved
#	if (typeof(highscoresArr) != TYPE_ARRAY) or (highscoresArr.size() == 0):
#		var fileApi = File.new();
#
#		# if there is no file, set as empty array
#		if not fileApi.file_exists(FILE_NAME):
#			highscoresArr = [];
#		else:
#			fileApi.open("user://savegame.save", File.READ);
#
#			# else, get the info from json inside file
#			while not fileApi.eof_reached():
#				var gameState = parse_json(fileApi.get_line());
#				highscoresArr = gameState.HIGHSCORES;
#
#			# close file
#			fileApi.close()
#
#	# double check it is proper format, if not, empty array is sent.
#	if (typeof(highscoresArr) != TYPE_ARRAY):
#		highscoresArr = [];
#		print("highscore was not in proper format");
#
#	return highscoresArr;

#func setHighscores (paramVal : Array):
#	__gameState.HIGHSCORES = paramVal;
#	return;
	
func change_music(audio):
	var stream_music = get_tree().get_current_scene().get_node("sound_player_music")
	
	stream_music.set_stream(musicDict[audio])
	stream_music.play()
	pass
	
func play_sound_effect(sfx, bus, free):
	var stream_sfx = bus
	bus.connect("finished", self, "sfx_finished", [bus, free])
	
	stream_sfx.set_stream(sfxDict[sfx]) #sfx should be called from sfx dictionary
	stream_sfx.play()
	
	pass
	
func sfx_finished(bus,free):
	if free:
		bus.queue_free()
	pass
