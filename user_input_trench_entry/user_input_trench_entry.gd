extends HBoxContainer

#Data management for each row created



# Called when the node enters the scene tree for the first time.
func _ready():
	$delete_row.connect("button_up", self, "_call_pop_up")
	$delete_row_popup.connect("confirmed", self, "_delete_row")
	pass # Replace with function body.


func _call_pop_up():
	var pop_up = $delete_row_popup
	pop_up.popup_centered()
	return


func _delete_row():
	self.queue_free()
	return
